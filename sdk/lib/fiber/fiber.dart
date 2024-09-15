library dart.fiber;

part 'fiber_link.dart';
part 'fiber_processor.dart';
part 'fiber_factory.dart';

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

  @pragma("vm:prefer-inline")
  int get value => _state;

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

  @pragma("vm:prefer-inline")
  int get value => _attributes;

  @pragma("vm:prefer-inline")
  static FiberAttributes _calculate({required bool persistent}) {
    var attributes = _kFiberAttributeNothing;
    if (persistent) attributes |= _kFiberAttributePersistent;
    return FiberAttributes(attributes);
  }
}

extension type FiberArguments(List _arguments) {
  @pragma("vm:prefer-inline")
  dynamic operator [](int index) => _arguments[index];
  @pragma("vm:prefer-inline")
  List<dynamic> get value => _arguments;
}

class _Coroutine {
  external factory _Coroutine._(int size);

  external String get _name;
  external set _name(String value);

  external void Function() get _entry;
  external set _entry(void Function() value);

  external void Function() get _trampoline;
  external set _trampoline(void Function() value);

  external List get _arguments;
  external set _arguments(List value);

  external int get _state;
  external set _state(int value);

  external int get _attributes;
  external set _attributes(int value);

  external _Coroutine? get _caller;
  external set _caller(_Coroutine? value);

  external _Coroutine? get _scheduler;
  external set _scheduler(_Coroutine? value);

  external FiberProcessor get _processor;
  external set _processor(FiberProcessor value);

  external void _recycle();
  external void _dispose();

  external static _Coroutine? get _current;

  external static void _initialize(_Coroutine root);
  external static void _transfer(_Coroutine from, _Coroutine to);
  external static void _fork(_Coroutine from, _Coroutine to);
}

extension type Fiber(_Coroutine _coroutine) implements _Coroutine {
  @pragma("vm:prefer-inline")
  factory Fiber.child(
    void Function() entry, {
    List arguments = const [],
    bool persistent = false,
    int size = _kDefaultStackSize,
    String? name,
  }) =>
      _FiberFactory.child(
        entry,
        arguments: arguments,
        size: size,
        name: name,
        persistent: persistent,
      );

  @pragma("vm:prefer-inline")
  static void spawn(
    void Function() entry, {
    List arguments = const [],
    bool persistent = false,
    int size = _kDefaultStackSize,
    String? name,
  }) =>
      Fiber.fork(
        _FiberFactory.child(
          entry,
          arguments: arguments,
          size: size,
          name: name,
          persistent: persistent,
        ),
      );

  @pragma("vm:prefer-inline")
  static void fork(Fiber callee) {
    final caller = Fiber.current();
    if (callee.state.disposed || callee.state.running) throw StateError("Can't start a fiber in the state: ${callee.state.string()}");
    callee._caller = caller;
    _Coroutine._fork(caller!, callee);
  }

  @pragma("vm:prefer-inline")
  static void suspend() {
    final caller = Fiber.current();
    if (caller!._caller == null) throw StateError("Can't suspend: no caller for this fiber");
    final callee = caller._caller!;
    if (callee._state != _kFiberStateRunning) throw StateError("Destination fiber is not running, state = ${FiberState(callee._state).string()}");
    callee._caller = caller!._scheduler;
    _Coroutine._transfer(caller!, callee);
  }

  @pragma("vm:prefer-inline")
  static Fiber current() {
    final current = _Coroutine._current;
    if (current == null) throw StateError("Main fiber is not initialized");
    return Fiber(current!);
  }

  @pragma("vm:prefer-inline")
  static void schedule(Fiber fiber) {
    Fiber.current()._processor._schedule(fiber);
  }

  @pragma("vm:prefer-inline")
  FiberState get state => FiberState(_coroutine._state);

  @pragma("vm:prefer-inline")
  FiberAttributes get attributes => FiberAttributes(_coroutine._attributes);

  @pragma("vm:prefer-inline")
  FiberArguments get arguments => FiberArguments(_coroutine._arguments);

  @pragma("vm:never-inline")
  static void _run() {
    final current = _Coroutine._current!;
    current._entry();
    current._processor._finalize(Fiber(current));
  }
}