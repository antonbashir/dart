// Copyright (c) 2017, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

#include "vm/bootstrap_natives.h"

#include "vm/compiler/runtime_api.h"
#include "vm/coroutine.h"
#include "vm/native_entry.h"

namespace dart {
DEFINE_NATIVE_ENTRY(Coroutine_create, 0, 5) {
  GET_NON_NULL_NATIVE_ARGUMENT(Smi, size, arguments->NativeArgAt(0));
  GET_NON_NULL_NATIVE_ARGUMENT(Smi, owner_index, arguments->NativeArgAt(1));
  GET_NON_NULL_NATIVE_ARGUMENT(Instance, owner, arguments->NativeArgAt(2));
  GET_NON_NULL_NATIVE_ARGUMENT(Smi, attributes, arguments->NativeArgAt(3));
  GET_NON_NULL_NATIVE_ARGUMENT(Closure, trampoline, arguments->NativeArgAt(4));
  auto coroutine = (intptr_t)Coroutine::New(
      size.Value(), owner_index.Value(), owner.ptr(), attributes.Value(),
      Function::Handle(trampoline.function()).entry_point());
  return Smi::New(coroutine);
}
}  // namespace dart
