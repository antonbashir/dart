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

  factory Fiber.main({required int size, required void Function() entry}) {
    Fiber._main = Fiber(size: size, entry: entry, name: "main");
    print("after constructor");
    return Fiber._main;
  }

  external FiberState get state;

  external Fiber({required int size, required void Function() entry, required String name});

  external void start();

  external void transfer(Fiber to);

  external void fork(Fiber to);
}
