library dart.fiber;

import 'dart:ffi';

enum FiberState {
  created,
  initialized,
  running,
  finished,
}

class Fiber {
  final String name;
  external FiberState get state;
  external Fiber({required int size, required void Function() entry, required String name});
  external void construct();
  external void start();
  external void transfer(Fiber to);
}