// Copyright (c) 2017, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

#include <sys/mman.h>
#include "platform/globals.h"
#include "vm/bootstrap_natives.h"

#include "vm/compiler/runtime_api.h"
#include "vm/native_entry.h"

namespace dart {
DEFINE_NATIVE_ENTRY(Coroutine_factory, 0, 3) {
  GET_NON_NULL_NATIVE_ARGUMENT(Smi, size, arguments->NativeArgAt(1));
  GET_NON_NULL_NATIVE_ARGUMENT(Closure, entry, arguments->NativeArgAt(2));
  uintptr_t stack_size = size.Value();
  void** stack_base = (void**)((uintptr_t)mmap(0, stack_size * kWordSize, PROT_READ | PROT_WRITE | PROT_EXEC, MAP_PRIVATE | MAP_ANONYMOUS, -1, 0) + stack_size);
  return Coroutine::New(stack_base , stack_size, Function::Handle(entry.function()).ptr());
}
}  // namespace dart
