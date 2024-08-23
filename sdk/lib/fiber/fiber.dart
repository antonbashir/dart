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
}

class Fiber {
  var _state = FiberState.created;
  FiberState get state => _state;

  external Fiber({required FiberStack stack, required void Function() entry});

  void suspend() => _suspend();
  
  void resume() => _resume();
  
  void transfer(Fiber to) => _transfer(to);

  void run() {
    if (_state == FiberState.created) {
      _state = FiberState.launched;
      _run();
      _state = FiberState.running;
    }
  }

  external void _run();
  external void _resume();
  external void _suspend();
  external void _transfer(Fiber to);
}
