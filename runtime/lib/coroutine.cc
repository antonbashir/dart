// Copyright (c) 2017, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

#include "vm/bootstrap_natives.h"

#include "vm/compiler/runtime_api.h"
#include "vm/native_entry.h"

namespace dart {
DEFINE_NATIVE_ENTRY(Coroutine_factory, 0, 3) {
  GET_NON_NULL_NATIVE_ARGUMENT(Smi, size, arguments->NativeArgAt(1));
  GET_NON_NULL_NATIVE_ARGUMENT(Closure, trampoline, arguments->NativeArgAt(2));
  return Coroutine::New(size.Value(), trampoline.function());
}
}  // namespace dart
 