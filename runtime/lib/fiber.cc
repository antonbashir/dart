// Copyright (c) 2017, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

#include "vm/bootstrap_natives.h"

#include "vm/compiler/method_recognizer.h"
#include "vm/compiler/runtime_api.h"
#include "vm/native_entry.h"

namespace dart {

static uword extract_function(const Instance& instance, Zone* zone) {
  uword entry;
  if (instance.IsClosure()) {
    entry = Function::Handle(zone, Closure::Cast(instance).function())
                .entry_point();
  }
  if (instance.IsFunction()) {
    entry = Function::Cast(instance).entry_point();
  }
  return entry;
}

DEFINE_NATIVE_ENTRY(Coroutine_factory, 0, 5) {
  GET_NON_NULL_NATIVE_ARGUMENT(Pointer, stack, arguments->NativeArgAt(1));
  GET_NON_NULL_NATIVE_ARGUMENT(Smi, size, arguments->NativeArgAt(2));
  GET_NON_NULL_NATIVE_ARGUMENT(Instance, entry_instance,
                               arguments->NativeArgAt(3));
  GET_NON_NULL_NATIVE_ARGUMENT(Instance, initialize_instance,
                               arguments->NativeArgAt(4));
  uword entry = extract_function(entry_instance, zone);
  uword initialize = extract_function(initialize_instance, zone);
  return Coroutine::New(stack.NativeAddress(), size.AsTruncatedUint32Value(),
                        entry, initialize);
}
}  // namespace dart
