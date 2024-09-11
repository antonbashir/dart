// Copyright (c) 2017, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

#include <sys/mman.h>
#include "platform/globals.h"
#include "vm/bootstrap_natives.h"

#include "vm/compiler/runtime_api.h"
#include "vm/native_entry.h"

namespace dart {
DEFINE_NATIVE_ENTRY(Coroutine_factory, 0, 5) {
  GET_NON_NULL_NATIVE_ARGUMENT(Smi, attributes, arguments->NativeArgAt(1));
  GET_NON_NULL_NATIVE_ARGUMENT(Smi, size, arguments->NativeArgAt(2));
  GET_NON_NULL_NATIVE_ARGUMENT(Closure, entry, arguments->NativeArgAt(3));
  GET_NON_NULL_NATIVE_ARGUMENT(Closure, trampoline, arguments->NativeArgAt(4));
  intptr_t stack_size = size.Value();
#if defined(DART_TARGET_OS_WINDOWS)
  void** stack_base = (void**)((uintptr_t)VirtualAlloc(
      nullptr, stack_size * kWordSize, MEM_RESERVE | MEM_COMMIT,
      PAGE_READWRITE));
#else
  void** stack_base = (void**)((uintptr_t)mmap(
      nullptr, stack_size * kWordSize, PROT_READ | PROT_WRITE | PROT_EXEC,
      MAP_PRIVATE | MAP_ANONYMOUS, -1, 0));
#endif
  memset(stack_base, 0, stack_size * kWordSize);
  return Coroutine::New(stack_base + stack_size, attributes.Value(), stack_size,
                        entry, Function::Handle(trampoline.function()));
}

DEFINE_NATIVE_ENTRY(Coroutine_recycle, 0, 1) {
  GET_NON_NULL_NATIVE_ARGUMENT(Coroutine, coroutine, arguments->NativeArgAt(0));
  coroutine.Recycle();
  return Object::null();
}

DEFINE_NATIVE_ENTRY(Coroutine_dispose, 0, 1) {
  GET_NON_NULL_NATIVE_ARGUMENT(Coroutine, coroutine, arguments->NativeArgAt(0));
#if defined(DART_TARGET_OS_WINDOWS)
  VirtualFree((void**)coroutine.stack_limit(), 0, MEM_RELEASE);
#else
  munmap((void**)coroutine.stack_limit(),
         (uword)(coroutine.stack_base() - coroutine.stack_limit()) * kWordSize);
#endif
  coroutine.Dispose();
  return Object::null();
}
}  // namespace dart
