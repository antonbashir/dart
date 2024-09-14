// Copyright (c) 2017, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

#include "vm/bootstrap_natives.h"

#include "vm/compiler/runtime_api.h"
#include "vm/native_entry.h"

namespace dart {
DEFINE_NATIVE_ENTRY(Coroutine_factory, 0, 6) {
  GET_NON_NULL_NATIVE_ARGUMENT(Smi, size, arguments->NativeArgAt(1));
  GET_NON_NULL_NATIVE_ARGUMENT(Smi, attributes, arguments->NativeArgAt(2));
  GET_NON_NULL_NATIVE_ARGUMENT(Closure, entry, arguments->NativeArgAt(3));
  GET_NON_NULL_NATIVE_ARGUMENT(Closure, trampoline, arguments->NativeArgAt(4));
  GET_NON_NULL_NATIVE_ARGUMENT(Instance, fiber, arguments->NativeArgAt(5));
  return Coroutine::New(size.Value(), attributes.Value(), entry,
                        Function::Handle(trampoline.function()), fiber);
}

DEFINE_NATIVE_ENTRY(Coroutine_recycle, 0, 1) {
  GET_NON_NULL_NATIVE_ARGUMENT(Coroutine, coroutine, arguments->NativeArgAt(0));
  coroutine.Recycle();
  return Object::null();
}

DEFINE_NATIVE_ENTRY(Coroutine_dispose, 0, 1) {
  GET_NON_NULL_NATIVE_ARGUMENT(Coroutine, coroutine, arguments->NativeArgAt(0));
  coroutine.Dispose();
  return Object::null();
}
}  // namespace dart
