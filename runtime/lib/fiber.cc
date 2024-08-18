// Copyright (c) 2017, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

#include "vm/bootstrap_natives.h"

#include "vm/native_entry.h"

namespace dart {
DEFINE_NATIVE_ENTRY(Fiber_suspend, 0, 0) {
  OS::Print("Suspend\n");
  return Object::null();
}

DEFINE_NATIVE_ENTRY(Coroutine_factory, 0, 2) {
  ASSERT(
      TypeArguments::CheckedHandle(zone, arguments->NativeArgAt(0)).IsNull());
  GET_NON_NULL_NATIVE_ARGUMENT(Smi, stack_size, arguments->NativeArgAt(1));
  return Coroutine::New(stack_size.AsInt64Value());
}
}  // namespace dart
