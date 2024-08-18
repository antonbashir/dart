// Copyright (c) 2017, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

#include "vm/bootstrap_natives.h"

#include "vm/compiler/method_recognizer.h"
#include "vm/compiler/runtime_api.h"
#include "vm/native_entry.h"

namespace dart {
DEFINE_NATIVE_ENTRY(Coroutine_factory, 0, 4) {
  GET_NON_NULL_NATIVE_ARGUMENT(Pointer, stack, arguments->NativeArgAt(1));
  GET_NON_NULL_NATIVE_ARGUMENT(Smi, size, arguments->NativeArgAt(2));
  GET_NON_NULL_NATIVE_ARGUMENT(Instance, entry_instance,
                               arguments->NativeArgAt(3));
  uword entry;
  if (entry_instance.IsClosure()) {
    entry = Function::Handle(zone, Closure::Cast(entry_instance).function())
                .entry_point();
  }
  if (entry_instance.IsFunction()) {
    entry = Function::Cast(entry_instance).entry_point();
  }
  return Coroutine::New(stack.NativeAddress(), size.AsTruncatedUint32Value(),
                        entry);
}
}  // namespace dart
