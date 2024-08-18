library dart.fiber;

import 'dart:ffi';

extension type FiberStack(({Pointer<Void> pointer, int size}) _stack) {
  int get size => _stack.size;

  Pointer<Void> get pointer => _stack.pointer;
}

enum FiberState {
  created,
  running,
}

class Fiber {
  var _state = FiberState.created;
  FiberState get state => _state;

  external Fiber({required FiberStack stack, required void Function() entry});

  void run() {
    if (_state == FiberState.created) {
      _state = FiberState.running;
      _run();
    }
  }

  external void _run();
}
