library dart.fiber;

import 'dart:ffi';

extension type FiberStack(({Pointer<Void> pointer, int size}) _stack) {
  int get size => _stack.size;

  Pointer<Void> get pointer => _stack.pointer;
}

enum FiberState {
  created,
  launched,
  running,
  finished,
}

class Fiber {
  external FiberState get state;
  external Fiber({required FiberStack stack, required void Function() entry});
  external void start();
  external void transfer(Fiber to);
}
