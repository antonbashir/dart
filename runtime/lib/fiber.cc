// Copyright (c) 2017, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

#include "vm/bootstrap_natives.h"

#include "vm/compiler/method_recognizer.h"
#include "vm/compiler/runtime_api.h"
#include "vm/native_entry.h"
#include "vm/tagged_pointer.h"

namespace dart {

DEFINE_NATIVE_ENTRY(Coroutine_factory, 0, 2) {
  GET_NON_NULL_NATIVE_ARGUMENT(Pointer, stack, arguments->NativeArgAt(1));
  return Coroutine::New(stack.NativeAddress());
}
}  // namespace dart
