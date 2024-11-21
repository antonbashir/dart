library dart.fiber;

part 'fiber_processor.dart';
part 'fiber_factory.dart';

const _kDefaultStackSize = 512 * (1 << 10);
const _kSchedulerStackSize = 256 * (1 << 10);
const _kMainFiber = "main";
const _kSchedulerFiber = "scheduler";

const _kFiberNothing = 0;
const _kFiberCreated = 1 << 0;
const _kFiberRunning = 1 << 1;
const _kFiberSuspended = 1 << 2;
const _kFiberFinished = 1 << 3;
const _kFiberDisposed = 1 << 4;
const _kFiberPersistent = 1 << 5;

enum FiberStateKind { created, running, suspended, finished, disposed, unknown }

extension type FiberState(int _state) {
  @pragma("vm:prefer-inline")
  bool get created => _state & _kFiberCreated != 0;

  @pragma("vm:prefer-inline")
  bool get running => _state & _kFiberRunning != 0;

  @pragma("vm:prefer-inline")
  bool get suspended => _state & _kFiberSuspended != 0;

  @pragma("vm:prefer-inline")
  bool get finished => _state & _kFiberFinished != 0;

  @pragma("vm:prefer-inline")
  bool get disposed => _state & _kFiberDisposed != 0;

  @pragma("vm:prefer-inline")
  int get value => _state;

  @pragma("vm:prefer-inline")
  FiberStateKind get kind {
    if (created) return FiberStateKind.created;
    if (running) return FiberStateKind.running;
    if (suspended) return FiberStateKind.suspended;
    if (finished) return FiberStateKind.finished;
    if (disposed) return FiberStateKind.disposed;
    return FiberStateKind.unknown;
  }
}

extension type FiberAttributes(int _attributes) {
  @pragma("vm:prefer-inline")
  bool get persistent => _attributes & _kFiberPersistent != 0;

  @pragma("vm:prefer-inline")
  bool get ephemeral => !persistent;

  @pragma("vm:prefer-inline")
  int get value => _attributes;

  @pragma("vm:prefer-inline")
  static FiberAttributes _calculate({required bool persistent}) {
    var attributes = _kFiberCreated;
    if (persistent) attributes |= _kFiberPersistent;
    return FiberAttributes(attributes);
  }
}

extension type FiberArgument(Object? _argument) {
  @pragma("vm:prefer-inline")
  T? single<T>() => _argument as T?;

  @pragma("vm:prefer-inline")
  T? positioned<T>(int index) => _argument == null ? null : asArray![index];

  @pragma("vm:prefer-inline")
  T? named<T>(String key) => _argument == null ? null : asMap![key];

  @pragma("vm:prefer-inline")
  List? get asArray => _argument == null ? [] : _argument as List;

  @pragma("vm:prefer-inline")
  Map? get asMap => _argument == null ? {} : _argument as Map;
}

extension type FiberRegistry(List<Fiber> _registry) implements Iterable<Fiber> {
  @pragma("vm:prefer-inline")
  int get length => _registry.length;
}

extension type Fiber(_Coroutine _coroutine) implements _Coroutine {
  @pragma("vm:prefer-inline")
  factory Fiber.child(
    void Function() entry, {
    bool persistent = false,
    int size = _kDefaultStackSize,
    String? name,
    Object? argument,
  }) =>
      _FiberFactory._child(
        entry,
        argument: argument,
        size: size,
        name: name,
        persistent: persistent,
      );

  @pragma("vm:prefer-inline")
  static Fiber launch(
    void Function() entry, {
    int size = _kDefaultStackSize,
    void Function()? idle,
    Object? argument,
  }) =>
      _FiberProcessor(idle)._process(
        entry,
        argument: argument,
        size: size,
      );

  @pragma("vm:prefer-inline")
  static Fiber spawn(
    void Function() entry, {
    bool persistent = false,
    int size = _kDefaultStackSize,
    String? name,
    Object? argument,
  }) {
    final child = _FiberFactory._child(
      entry,
      size: size,
      name: name,
      argument: argument,
      persistent: persistent,
    );
    Fiber.fork(child);
    return child;
  }

  @pragma("vm:prefer-inline")
  static void fork(Fiber callee) {
    final caller = Fiber.current;
    assert(callee.state.created || callee.state.finished);
    callee._caller = caller;
    caller._attributes = (caller._attributes & ~_kFiberRunning) | _kFiberSuspended;
    callee._attributes = (callee._attributes & ~_kFiberCreated & ~_kFiberFinished) | _kFiberRunning;
    _Coroutine._fork(caller, callee);
  }

  @pragma("vm:prefer-inline")
  static void suspend() {
    final caller = Fiber.current;
    final callee = Fiber(caller._caller);
    assert(callee.state.suspended || identical(callee, caller!._scheduler));
    caller._caller = caller._scheduler;
    _Coroutine._transfer(caller, callee);
  }

  @pragma("vm:prefer-inline")
  static Fiber get current {
    final current = _Coroutine._current;
    assert(current != null);
    return Fiber(current!);
  }

  @pragma("vm:prefer-inline")
  static FiberRegistry get registry => FiberRegistry(_Coroutine._registry as List<Fiber>);

  @pragma("vm:prefer-inline")
  static void schedule(Fiber fiber) {
    assert(fiber.state.suspended || fiber.state.running);
    Fiber.current._processor._schedule(fiber);
  }

  @pragma("vm:prefer-inline")
  static void reschedule() {
    Fiber.schedule(Fiber.current);
    Fiber.suspend();
  }

  @pragma("vm:prefer-inline")
  int get index => _coroutine._index;

  @pragma("vm:prefer-inline")
  int get size => _coroutine._size;

  @pragma("vm:prefer-inline")
  String get name => _coroutine._name;

  @pragma("vm:prefer-inline")
  FiberState get state => FiberState(_coroutine._attributes);

  @pragma("vm:prefer-inline")
  FiberAttributes get attributes => FiberAttributes(_coroutine._attributes);

  @pragma("vm:prefer-inline")
  FiberArgument get argument => FiberArgument(_coroutine._argument);

  @pragma("vm:never-inline")
  static void _run() => _Coroutine._current!._entry();
}

class _Coroutine {
  external factory _Coroutine._(int size, Function trampoline);

  external String get _name;
  external set _name(String value);

  external int get _index;

  external int get _size;

  external void Function() get _entry;
  external set _entry(void Function() value);

  external void Function() get _trampoline;
  external set _trampoline(void Function() value);

  external Object? get _argument;
  external set _argument(Object? value);

  external int get _attributes;
  external set _attributes(int value);

  external _Coroutine get _caller;
  external set _caller(_Coroutine value);

  external _Coroutine get _scheduler;
  external set _scheduler(_Coroutine value);

  external _FiberProcessor get _processor;
  external set _processor(_FiberProcessor value);

  external _Coroutine get _toProcessorNext;
  external set _toProcessorNext(_Coroutine value);

  external _Coroutine get _toProcessorPrevious;
  external set _toProcessorPrevious(_Coroutine value);

  external static _Coroutine? get _current;

  external static List<_Coroutine> get _registry;

  external static void _initialize(_Coroutine root);

  external static void _transfer(_Coroutine from, _Coroutine to);

  external static void _fork(_Coroutine from, _Coroutine to);
}
