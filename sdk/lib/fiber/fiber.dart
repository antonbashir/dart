library dart.fiber;

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
  external void start();
  external void transfer(Fiber to);
  external void fork(Fiber to);
}