library dart.fiber;

import 'dart:ffi';

extension type FiberStack(({Pointer<Void> pointer, int size}) _stack) {
  int get size => _stack.size;

  Pointer<Void> get pointer => _stack.pointer; 
}

class Fiber {
  external Fiber({required FiberStack stack, required void Function() entry});
}
