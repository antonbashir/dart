#include "coroutine.h"
#include "vm/heap/safepoint.h"
#include "vm/stack_frame.h"

#if !defined(DART_TARGET_OS_WINDOWS)
#include <sys/mman.h>
#endif

#include "vm/dart_api_state.h"
#include "vm/isolate.h"
#include "vm/thread.h"
#include "vm/zone.h"

namespace dart {
Coroutine* Coroutine::New(uword size,
                          uword owner_index,
                          ObjectPtr owner,
                          uword attributes,
                          uword trampoline) {
  auto isolate = Isolate::Current();
  auto& registry = isolate->coroutines_registry();
  auto page_size = VirtualMemory::PageSize();
  auto stack_size_ = (size + page_size - 1) & ~(page_size - 1);

  const auto coroutine = new Coroutine();
#if defined(DART_TARGET_OS_WINDOWS)
  void* stack_base = (void*)((uword)VirtualAlloc(
      nullptr, stack_size, MEM_RESERVE | MEM_COMMIT, PAGE_READWRITE));
#else
  void* stack_end = (void*)((uword)mmap(nullptr, stack_size_,
                                        PROT_READ | PROT_WRITE | PROT_EXEC,
                                        MAP_PRIVATE | MAP_ANONYMOUS, -1, 0));
#endif
  auto stack_limit = (uword)(stack_end);
  auto stack_base = (uword)(stack_size_ + (char*)stack_end);

  coroutine->attributes_ = attributes;
  coroutine->stack_size_ = stack_size_;
  coroutine->native_stack_base_ = (uword) nullptr;
  coroutine->stack_root_ = stack_base;
  coroutine->stack_base_ = stack_base;
  coroutine->stack_limit_ = stack_limit;
  coroutine->overflow_stack_limit_ =
      stack_limit + calculate_headroom(stack_base - stack_limit);
  coroutine->trampoline_ = trampoline;
  coroutine->index_ = registry.length();
  coroutine->owner_ = owner_index;

  FinalizablePersistentHandle::New(IsolateGroup::Current(),
                                   Object::Handle(owner), coroutine, free,
                                   sizeof(Coroutine), true);

  registry.Add(coroutine);

  return coroutine;
}

void Coroutine::free(void* isolate_callback_data, void* peer) {
  delete reinterpret_cast<Coroutine*>(peer);
}

void Coroutine::dispose(Thread* thread, Zone* zone) {
  change_state(CoroutineAttributes::created | CoroutineAttributes::running |
                   CoroutineAttributes::suspended,
               CoroutineAttributes::disposed);
  set_trampoline((uword) nullptr);
#if defined(DART_TARGET_OS_WINDOWS)
  VirtualFree((void*)stack_limit(), 0, MEM_RELEASE);
#else
  munmap((void*)stack_limit(), stack_size());
#endif
  stack_size_ = (uword)0;
  native_stack_base_ = (uword) nullptr;
  stack_root_ = (uword) nullptr;
  stack_base_ = (uword) nullptr;
  stack_limit_ = (uword) nullptr;
  overflow_stack_limit_ = (uword) nullptr;
  Thread::Current()->isolate()->coroutines_registry().data()[index_] = nullptr;
  index_ = -1;
}

void Coroutine::HandleJumpToFrame(Thread* thread, uword stack_pointer) {
  auto zone = thread->zone();
  auto& coroutines = thread->isolate()->coroutines_registry();
  Coroutine* found = nullptr;
  for (auto index = 0; index < coroutines.length(); index++) {
    auto& candidate = coroutines[index];
    if (candidate == nullptr) {
      continue;
    }
    if (stack_pointer > candidate->stack_limit() &&
        stack_pointer <= candidate->stack_root()) {
      found = candidate;
      break;
    }
  }
  if (found == nullptr) {
    HandleRootExit(thread, zone);
    return;
  }
  if (found == this) {
    return;
  }
  MutexLocker lock(Thread::Current()->isolate()->group()->coroutine_mutex());
  dispose(thread, zone);
  found->change_state(CoroutineAttributes::suspended,
                      CoroutineAttributes::running);
  thread->EnterCoroutine(found);
}

void Coroutine::HandleRootEnter(Thread* thread, Zone* zone) {
  MutexLocker lock(Thread::Current()->isolate()->group()->coroutine_mutex());
  thread->EnterCoroutine(this);
}

void Coroutine::HandleRootExit(Thread* thread, Zone* zone) {
  MutexLocker lock(Thread::Current()->isolate()->group()->coroutine_mutex());
  auto& coroutines = thread->isolate()->coroutines_registry();

  for (auto index = 0; index < coroutines.length(); index++) {
    auto coroutine = coroutines[index];
    if (coroutine == nullptr) {
      continue;
    }
    if (coroutine->is_ephemeral() && !coroutine->is_disposed()) {
      coroutine->dispose(thread, zone);
    }
  }

  coroutines.TruncateTo(0);
  thread->isolate()->set_coroutines_registry(MallocGrowableArray<Coroutine*>(
      FLAG_coroutines_registry_initial_capacity));
  thread->ExitCoroutine();
}

void Coroutine::HandleForkedEnter(Thread* thread, Zone* zone) {
  MutexLocker lock(Thread::Current()->isolate()->group()->coroutine_mutex());
  thread->EnterCoroutine(this);
}

void Coroutine::HandleForkedExit(Thread* thread, Zone* zone) {
  MutexLocker lock(Thread::Current()->isolate()->group()->coroutine_mutex());
  auto saved_caller = caller();
  auto new_caller_state =
      (saved_caller->attributes() & ~CoroutineAttributes::suspended) |
      CoroutineAttributes::running;
  saved_caller->set_attributes(new_caller_state);
  dispose(thread, zone);
  thread->EnterCoroutine(saved_caller);
}

void Coroutine::VisitStack(Coroutine* coroutine,
                           ObjectPointerVisitor* visitor) {
  auto stack = coroutine->stack_base();
  ASSERT(stack != 0);
  auto native_stack = coroutine->native_stack_base();
  Thread* thread = Thread::Current();
  const uword stub_fp = *reinterpret_cast<uword*>(stack);
  StackFrameIterator coroutine_frames_iterator(
      stub_fp, ValidationPolicy::kDontValidateFrames, thread,
      StackFrameIterator::kAllowCrossThreadIteration,
      StackFrameIterator::kStackOwnerCoroutine);
  StackFrame* frame = coroutine_frames_iterator.NextFrame();
  while (frame != nullptr) {
    frame->VisitObjectPointers(visitor);
    frame = coroutine_frames_iterator.NextFrame();
    if (frame != nullptr &&
        StubCode::InCoroutineForkStub(frame->GetCallerPc())) {
      frame->VisitObjectPointers(visitor);
      break;
    }
    if (frame != nullptr &&
        StubCode::InCoroutineInitializeStub(frame->GetCallerPc())) {
      frame->VisitObjectPointers(visitor);
      const uword stub_fp = *reinterpret_cast<uword*>(native_stack);
      StackFrameIterator native_coroutine_frames_iterator(
          stub_fp, ValidationPolicy::kDontValidateFrames, thread,
          StackFrameIterator::kAllowCrossThreadIteration,
          StackFrameIterator::kStackOwnerCoroutine);
      StackFrame* frame = native_coroutine_frames_iterator.NextFrame();
      while (frame != nullptr) {
        frame->VisitObjectPointers(visitor);
        frame = native_coroutine_frames_iterator.NextFrame();
      }
      break;
    }
  }
}

}  // namespace dart
