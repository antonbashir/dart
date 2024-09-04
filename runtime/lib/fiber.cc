// Copyright (c) 2017, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

#include <sys/mman.h>
#include "vm/bootstrap_natives.h"

#include "vm/compiler/runtime_api.h"
#include "vm/native_entry.h"
#include "vm/virtual_memory.h"

namespace dart {
DEFINE_NATIVE_ENTRY(Coroutine_factory, 0, 3) {
  GET_NON_NULL_NATIVE_ARGUMENT(Smi, size, arguments->NativeArgAt(1));
  GET_NON_NULL_NATIVE_ARGUMENT(Closure, entry, arguments->NativeArgAt(2));
  VirtualMemory* stack_memory = VirtualMemory::AllocateStack(size.Value() * kWordSize);
  uintptr_t stack_size = stack_memory->size();
  void** stack_base = (void**)stack_memory->address() + stack_size;
  ASSERT(Utils::IsAligned(stack_base, OS::ActivationFrameAlignment()));
  ASSERT(Utils::IsAligned(stack_base-8, OS::ActivationFrameAlignment()));
  return Coroutine::New(stack_base, stack_size, Function::Handle(entry.function()).ptr());
}
}  // namespace dart
