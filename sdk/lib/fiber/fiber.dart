library dart.fiber;

import 'dart:ffi';

extension type FiberStack(({Pointer<Void> pointer, int size}) stack) {}

class Fiber {
  external Fiber({required FiberStack stack, required void Function() entry});
}
