library dart.fiber;

part 'fiber_link.dart';
part 'fiber_scheduler.dart';

const _kDefaultStackSize = 128 * (1 << 10);
const _kSchedulerStackSize = 8 * (1 << 10);
const _kMainFiber = "main";
const _kSchedulerFiber = "scheduler";

const _kFiberStateCreated = 0;
const _kFiberStateRunning = 1;
const _kFiberStateFinished = 2;
const _kFiberStateDisposed = 3;

const _kFiberAttributeNothing = 0;
const _kFiberAttributePersistent = 1 << 0;

extension type FiberState(int _state) {
  @pragma("vm:prefer-inline")
  bool get created => _state == _kFiberStateCreated;

  @pragma("vm:prefer-inline")
  bool get running => _state == _kFiberStateRunning;

  @pragma("vm:prefer-inline")
  bool get finished => _state == _kFiberStateFinished;

  @pragma("vm:prefer-inline")
  bool get disposed => _state == _kFiberStateDisposed;

  String string() {
    switch (_state) {
      case _kFiberStateCreated:
        return "created";
      case _kFiberStateRunning:
        return "running";
      case _kFiberStateFinished:
        return "finished";
      case _kFiberStateDisposed:
        return "disposed";
      default:
        return "unknown";
    }
  }
}

extension type FiberAttributes(int _attributes) {
  @pragma("vm:prefer-inline")
  bool get persistent => _attributes & _kFiberAttributePersistent > 0;
}

extension type FiberArguments(List _arguments) {
  @pragma("vm:prefer-inline")
  dynamic operator [](int index) => _arguments[index];
}

class _Coroutine {
  @pragma("vm:prefer-inline")
  static bool get _initialized => _current != null;
  
  @pragma("vm:prefer-inline")
  FiberScheduler get _scheduler => (_fiber as Fiber)._scheduler;
  
  @pragma("vm:prefer-inline")
  Fiber get _owner => _fiber as Fiber;
  
  external factory _Coroutine._(int size, int attributes, void Function() entry, void Function() trampoline, Object fiber, List arguments);
  external set _state(int value);
  external int get _state;
  external _Coroutine? get _caller;
  external set _caller(_Coroutine? value);
  external int get _attributes;
  external void Function() get _entry;
  external static _Coroutine? get _current;
  external Object get _fiber;
  external List get _arguments;
  external void _recycle();
  external void _dispose();
  external static void _initialize(_Coroutine root);
  external static void _transfer(_Coroutine from, _Coroutine to);
  external static void _fork(_Coroutine from, _Coroutine to);
}

class Fiber {
  final String name;
  late _Coroutine _coroutine;
  late FiberScheduler _scheduler;

  Fiber._(this.name);

  @pragma("vm:prefer-inline")
  static void spawn(
    void Function() entry, {
    List arguments = const [],
    bool run = true,
    bool persistent = false,
    int size = _kDefaultStackSize,
    String? name,
  }) =>
      Fiber.fork(
        Fiber.child(
          entry,
          arguments: arguments,
          size: size,
          name: name,
          run: run,
          persistent: persistent,
        ),
      );

  @pragma("vm:prefer-inline")
  static void fork(Fiber to) {
    final current = _Coroutine._current;
    if (current == null) throw StateError("Main fiber is not initialized. Create main fiber before forking others");
    if (to.state.disposed || to.state.running) throw StateError("Can't start a fiber in the state: ${to.state.string()}");
    to._scheduler = current!._scheduler;
    to._coroutine._caller = current;
    _Coroutine._fork(current!, to._coroutine);
  }

  @pragma("vm:prefer-inline")
  static void suspend() {
    final current = _Coroutine._current;
    if (current == null) throw StateError("Main fiber is not initialized. Create main fiber before suspending");
    if (current!._caller == null) throw StateError("Can't suspend: no caller for this fiber");
    final caller = current!;
    final callee = caller._caller!;
    if (callee._state != _kFiberStateRunning) throw StateError("Destination fiber is not running, state = ${FiberState(callee._state).string()}");
    caller._caller = current!._scheduler._scheduler._coroutine;
    _Coroutine._transfer(current!, caller);
  }

  @pragma("vm:prefer-inline")
  static void transfer(Fiber to) {
    final caller = _Coroutine._current;
    if (caller == null) throw StateError("Main fiber is not initialized. Create main fiber before transfer to others");
    if (!to.state.running) throw StateError("Destination fiber is not running");
    final callee = to._coroutine;
    callee._caller = caller;
    _Coroutine._transfer(caller!, callee);
  }

  @pragma("vm:prefer-inline")
  static Fiber current() {
    final current = _Coroutine._current;
    if (current == null) throw StateError("Main fiber is not initialized");
    return current!._owner;
  }

  @pragma("vm:prefer-inline")
  factory Fiber.child(
    void Function() entry, {
    List arguments = const [],
    int size = _kDefaultStackSize,
    bool run = true,
    bool persistent = false,
    String? name,
  }) {
    final fiber = Fiber._(name ?? entry.toString());
    fiber._coroutine = _Coroutine._(
      size,
      _calculateAttributes(persistent: persistent),
      entry,
      run ? _run : _defer,
      fiber,
      arguments,
    );
    return fiber;
  }

  @pragma("vm:prefer-inline")
  factory Fiber._scheduler(FiberScheduler scheduler, void Function() entry) {
    final fiber = Fiber._(_kSchedulerFiber);
    fiber._scheduler = scheduler;
    fiber._coroutine = _Coroutine._(
      _kSchedulerStackSize,
      Fiber._calculateAttributes(persistent: false),
      entry,
      Fiber._run,
      fiber,
      [scheduler],
    );
    return fiber;
  }

  @pragma("vm:prefer-inline")
  factory Fiber._main(
    FiberScheduler scheduler,
    void Function() entry, {
    List arguments = const [],
    int size = _kDefaultStackSize,
    bool persistent = false,
  }) {
    final fiber = Fiber._(_kMainFiber);
    fiber._scheduler = scheduler;
    fiber._coroutine = _Coroutine._(
      size,
      Fiber._calculateAttributes(persistent: persistent),
      entry,
      Fiber._run,
      fiber,
      arguments,
    );
    return fiber;
  }

  @pragma("vm:prefer-inline")
  FiberState get state => FiberState(_coroutine._state);

  @pragma("vm:prefer-inline")
  FiberAttributes get attributes => FiberAttributes(_coroutine._attributes);

  @pragma("vm:prefer-inline")
  FiberArguments get arguments => FiberArguments(_coroutine._arguments);

  @pragma("vm:never-inline")
  static void _run() {
    _Coroutine._current!._entry();
  }

  @pragma("vm:never-inline")
  static void _defer() {
    _Coroutine._transfer(_Coroutine._current!, _Coroutine._current!._caller!);
    _Coroutine._current!._entry();
  }

  @pragma("vm:prefer-inline")
  static int _calculateAttributes({required bool persistent}) {
    var attributes = _kFiberAttributeNothing;
    if (persistent) attributes |= _kFiberAttributePersistent;
    return attributes;
  }
}
