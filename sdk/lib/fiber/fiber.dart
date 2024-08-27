library dart.fiber;

import "dart:async" show FutureOr;

enum FiberState {
  created,
  initialized,
  running,
  finished,
}

class Fiber {
  final String name;
  static late Fiber _main;

  external FiberState get state;
  external factory Fiber.child({required int size, required void Function() entry, required String name});
  external factory Fiber.main({required int size, required void Function() entry});
  external void start();
  external void transfer(Fiber to);
  external void fork(Fiber to);
}
