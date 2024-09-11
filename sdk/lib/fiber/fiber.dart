library dart.fiber;

const _kDefaultStackSize = 128 * (1 << 10);
const _kMainFiber = "main";

const _kFiberStateCreated = 0;
const _kFiberStateRunning = 1;
const _kFiberStateFinished = 2;

extension type FiberState(int state) {
  @pragma("vm:prefer-inline")
  get created => state == _kFiberStateCreated;
  @pragma("vm:prefer-inline")
  get running => state == _kFiberStateRunning;
  @pragma("vm:prefer-inline")
  get finished => state == _kFiberStateFinished;

  String string() {
    switch (state) {
      case _kFiberStateCreated:
        return "created";
      case _kFiberStateRunning:
        return "running";
      case _kFiberStateFinished:
        return "finished";
      default:
        return "unknown";
    }
  }
}

class _Coroutine {
  @pragma("vm:prefer-inline")
  static bool get _initialized => _current != null;

  external factory _Coroutine._(int size, void Function() entry, void Function() trampoline);
  external set _state(int value);
  external int get _state;
  external _Coroutine? get _caller;
  external set _caller(_Coroutine? value);
  external void Function() get _entry;
  external static _Coroutine? get _current;
  external static void _initialize(_Coroutine root);
  external static void _transfer(_Coroutine from, _Coroutine to);
  external static void _fork(_Coroutine from, _Coroutine to);
}

extension type Fiber(_Coroutine _coroutine) {
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
    final current = _Coroutine._current;
    if (current == null) throw StateError("Main fiber is not initialized. Create main fiber before forking others");
    if (!to.state.created && !to.state.finished) throw StateError("Can't start a fiber in the state: ${to.state}");
    _Coroutine._fork(current!, to._coroutine);
  }

  @pragma("vm:prefer-inline")
  static void suspend() {
    final current = _Coroutine._current;
    if (current == null) throw StateError("Main fiber is not initialized. Create main fiber before suspending");
    if (current!._caller == null) throw StateError("Can't suspend: no caller for this fiber");
    _Coroutine._transfer(current!, current!._caller!);
  }

  @pragma("vm:prefer-inline")
  static void transfer(Fiber to) {
    final current = _Coroutine._current;
    if (current == null) throw StateError("Main fiber is not initialized. Create main fiber before transfer to others");
    if (!to.state.running) throw StateError("Destination fiber is not running");
    _Coroutine._transfer(current!, to._coroutine);
  }

  @pragma("vm:prefer-inline")
  static Fiber current() {
    final current = _Coroutine._current;
    if (current == null) throw StateError("Main fiber is not initialized");
    return Fiber(current!);
  }

  @pragma("vm:prefer-inline")
  void start() {
    if (_Coroutine._initialized) throw StateError("Main fiber already initialized");
    if (!state.created && !state.finished) throw StateError("Can't start a fiber in the state: ${state.string()}");
    _Coroutine._initialize(_coroutine);
  }

  @pragma("vm:prefer-inline")
  FiberState get state => FiberState(_coroutine._state);

  @pragma("vm:prefer-inline")
  factory Fiber.main(
    void Function() entry, {
    int size = _kDefaultStackSize,
  }) =>
      Fiber(_Coroutine._(size, entry, _run));

  @pragma("vm:prefer-inline")
  factory Fiber.child(
    void Function() entry, {
    int size = _kDefaultStackSize,
    bool run = true,
    String? name,
  }) =>
      Fiber(_Coroutine._(size, entry, run ? _run : _defer));

  @pragma("vm:never-inline")
  static void _run() {
    _Coroutine._current!._entry();
    final current = _Coroutine._current!;
    if (current._caller != null) {
      while (current._caller!._state != _kFiberStateRunning) current._caller = current._caller!._caller;
    }
  }

  @pragma("vm:never-inline")
  static void _defer() {
    _Coroutine._transfer(_Coroutine._current!, _Coroutine._current!._caller!);
    _Coroutine._current!._entry();
    final current = _Coroutine._current!;
    if (current._caller != null) {
      while (current._caller!._state != _kFiberStateRunning) current._caller = current._caller!._caller;
    }
  }
}
