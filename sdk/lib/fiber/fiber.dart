library dart.fiber;

import 'dart:ffi';

enum FiberState {
  created,
  initialized,
  running,
  finished,
}

class Fiber {
  external FiberState get state;
  external Fiber({required int size, required void Function() entry});
  external void start();
  external void transfer(Fiber to);
}