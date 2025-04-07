// Copyright (c) 2013, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

#ifndef RUNTIME_VM_FIBER_H_
#define RUNTIME_VM_FIBER_H_

#if defined(SHOULD_NOT_INCLUDE_RUNTIME)
#error "Should not include runtime"
#endif

#include <stdio.h>
#include <stdlib.h>
#include <sys/types.h>

#include "platform/globals.h"
#include "vm/os_thread.h"
#include "vm/tagged_pointer.h"

namespace dart {
class Thread;
class ObjectPointerVisitor;

class Coroutine {
 public:
  enum CoroutineAttributes {
    nothing = 0,
    created = 1 << 0,
    running = 1 << 1,
    suspended = 1 << 2,
    finished = 1 << 3,
    disposed = 1 << 4,
    persistent = 1 << 5,
  };

  Coroutine(){};

  static Coroutine* New(uword size, uword owner_index, ObjectPtr owner, uword attributes, uword trampoline);

  static void VisitStack(Coroutine* coroutine, ObjectPointerVisitor* visitor);

  void HandleJumpToFrame(Thread* thread, uword stack_pointer);
  void HandleRootEnter(Thread* thread, Zone* zone);
  void HandleRootExit(Thread* thread, Zone* zone);
  void HandleForkedEnter(Thread* thread, Zone* zone);
  void HandleForkedExit(Thread* thread, Zone* zone);

  uword trampoline() const { return trampoline_; }
  void set_trampoline(uword trampoline) { trampoline_ = trampoline; }
  static uword trampoline_offset() {
    return OFFSET_OF(Coroutine, trampoline_);
  }

  DART_FORCE_INLINE
  uword attributes() const { return attributes_; }
  DART_FORCE_INLINE
  bool is_persistent() const {
    return (bool)(attributes() & CoroutineAttributes::persistent);
  }
  DART_FORCE_INLINE
  bool is_ephemeral() const { return !is_persistent(); }
  DART_FORCE_INLINE
  bool is_created() const {
    return (bool)(attributes() & CoroutineAttributes::created);
  }
  DART_FORCE_INLINE
  bool is_running() const {
    return (bool)(attributes() & CoroutineAttributes::running);
  }
  DART_FORCE_INLINE
  bool is_finished() const {
    return (bool)(attributes() & CoroutineAttributes::finished);
  }
  DART_FORCE_INLINE
  bool is_disposed() const {
    return (bool)(attributes() & CoroutineAttributes::disposed);
  }
  DART_FORCE_INLINE
  bool is_suspended() const {
    return (bool)(attributes() & CoroutineAttributes::suspended);
  }
  DART_FORCE_INLINE
  void set_attributes(uword value) { attributes_ = value; }
  DART_FORCE_INLINE
  void or_attribute(uword value) {
    set_attributes(attributes() | value);
  }
  DART_FORCE_INLINE
  void change_state(uword from_value, uword to_value) {
    set_attributes((attributes() & ~from_value) | to_value);
  }
  DART_FORCE_INLINE
  void and_attribute(uword value) {
    set_attributes(attributes() & value);
  }
  static uword attributes_offset() {
    return OFFSET_OF(Coroutine, attributes_);
  }

  uword index() const { return index_; }
  void set_index(uword index) { index_ = index; }
  static uword index_offset() { return OFFSET_OF(Coroutine, index_); }

  Coroutine* caller() const { return caller_; }
  static uword caller_offset() { return OFFSET_OF(Coroutine, caller_); }

  uword stack_size() const { return stack_size_; }
  static uword stack_size_offset() {
    return OFFSET_OF(Coroutine, stack_size_);
  }

  uword native_stack_base() const { return native_stack_base_; }
  static uword native_stack_base_offset() {
    return OFFSET_OF(Coroutine, native_stack_base_);
  }

  uword stack_root() const { return stack_root_; }
  static uword stack_root_offset() {
    return OFFSET_OF(Coroutine, stack_root_);
  }

  uword stack_base() const { return stack_base_; }
  static uword stack_base_offset() {
    return OFFSET_OF(Coroutine, stack_base_);
  }

  uword stack_limit() const { return stack_limit_; }
  static uword stack_limit_offset() {
    return OFFSET_OF(Coroutine, stack_limit_);
  }

  uword owner() const { return owner_; }
  static uword owner_offset() {
    return OFFSET_OF(Coroutine, owner_);
  }

  uword overflow_stack_limit() const { return overflow_stack_limit_; }
  static uword overflow_stack_limit_offset() {
    return OFFSET_OF(Coroutine, overflow_stack_limit_);
  }
  bool HasStackHeadroom() {
    return OSThread::GetCurrentStackPointer() > overflow_stack_limit_;
  }

 private:
  Coroutine* caller_;
  uword owner_;
  uword trampoline_;
  uword stack_size_;
  uword native_stack_base_;
  uword stack_root_;
  uword stack_base_;
  uword stack_limit_;
  uword overflow_stack_limit_;
  uword attributes_;
  uword index_;

  static uword calculate_headroom(uword stack_size) {
    uword headroom = OSThread::kStackSizeBufferFraction * stack_size;
    return (headroom > OSThread::kStackSizeBufferMax)
               ? OSThread::kStackSizeBufferMax
               : headroom;
  }

  static void free(void* isolate_callback_data, void* peer);

  void dispose(Thread* thread, Zone* zone);

  DISALLOW_COPY_AND_ASSIGN(Coroutine);
};
}  // namespace dart

#endif  // RUNTIME_VM_FIBER_H_
