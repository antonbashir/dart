library dart.fiber;

import "dart:async" show FutureOr;

const _kDefaultStackSize = 128 * (1 << 10);

enum FiberState {
  created,
  initialized,
  running,
  finished,
}

class Fiber {
  final String name;
  static late Fiber _main;

  external static void idle();

  external FiberState get state;
  external Fiber._({required int size, required void Function() entry, required String name});
  factory Fiber.main({int size = _kDefaultStackSize, required void Function() entry}) => Fiber._(size: size, entry: entry, name: "main");
  factory Fiber.child({int size = _kDefaultStackSize, required void Function() entry, required String name}) => Fiber._(size: size, entry: entry, name: name);
  external void start();
  external void transfer(Fiber to);
  external void fork(Fiber to);
}
