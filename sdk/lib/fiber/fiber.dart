library dart.fiber;

const _kDefaultStackSize = 128 * (1 << 10);
const _kMainFiber = "main";

enum FiberState {
  created,
  initialized,
  running,
  finished,
}

class Fiber {
  final String name;
  Fiber? _caller;

  static var _initialized = false;
  static late Fiber _owner;

  @pragma("vm:prefer-inline")
  static void spawn(
    void Function() entry, {
    bool run = true,
    int size = _kDefaultStackSize,
    String? name,
  }) =>
      Fiber.fork(Fiber.child(entry, size: size, name: name, run: run));

  @pragma("vm:prefer-inline")
  static void launch(
    void Function() entry, {
    int size = _kDefaultStackSize,
  }) =>
      Fiber.main(entry, size: size).start();

  @pragma("vm:prefer-inline")
  static void fork(Fiber to) {
    if (!Fiber._initialized) throw StateError("Main fiber is not initialized. Create main fiber before forking others");
    if (to.state != FiberState.created && to.state != FiberState.finished) throw StateError("Can't start a fiber in the state: ${to.state}");
    Fiber._owner._fork(to);
  }

  @pragma("vm:prefer-inline")
  static void suspend() {
    if (!Fiber._initialized) throw StateError("Main fiber is not initialized. Create main fiber before suspending");
    if (_owner._caller == null) throw StateError("Can't suspend: no caller for this fiber");
    _owner._transfer(_owner._caller!!);
  }

  @pragma("vm:prefer-inline")
  static void transfer(Fiber to) {
    if (!Fiber._initialized) throw StateError("Main fiber is not initialized. Create main fiber before transfer to others");
    if (to.state != FiberState.running) throw StateError("Destination fiber is not running");
    _owner._transfer(to);
  }

  @pragma("vm:prefer-inline")
  static Fiber current() {
    if (!Fiber._initialized) throw StateError("Main fiber is not initialized");
    return Fiber._owner;
  }

  @pragma("vm:prefer-inline")
  factory Fiber.main(
    void Function() entry, {
    int size = _kDefaultStackSize,
  }) =>
      Fiber._(size: size, entry: entry, name: _kMainFiber);

  @pragma("vm:prefer-inline")
  factory Fiber.child(
    void Function() entry, {
    int size = _kDefaultStackSize,
    bool run = true,
    String? name,
  }) =>
      Fiber._(size: size, entry: entry, name: name ?? entry.toString(), defer: !run);

  @pragma("vm:prefer-inline")
  void start() {
    if (Fiber._initialized) throw StateError("Main fiber already initialized");
    if (state != FiberState.created && state != FiberState.finished) throw StateError("Can't start a fiber in the state: $state");
    Fiber._initialized = true;
    try {
      _start();
    } finally {
      Fiber._initialized = false;
    }
  }

  external FiberState get state;

  external Fiber._({
    required int size,
    required void Function() entry,
    required String name,
    bool defer = false,
  });

  external void _start();

  external void _transfer(Fiber to);

  external void _fork(Fiber to);
}
