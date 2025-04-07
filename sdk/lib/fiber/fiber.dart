library dart.fiber;

part 'fiber_processor.dart';
part 'fiber_factory.dart';
part 'fiber_pool.dart';

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

extension type _Coroutine(int handle) {}

external _Coroutine? Coroutine_create(int size, int owner_index, Object owner, int attributes, Function trampoline);

external void Coroutine_initialize(_Coroutine root);
external void Coroutine_transfer(_Coroutine from, _Coroutine to);
external void Coroutine_fork(_Coroutine from, _Coroutine to);

external _Coroutine? Coroutine_current();

external int Coroutine_getIndex(_Coroutine coroutine);
external int Coroutine_getOwner(_Coroutine coroutine);

external int Coroutine_getAttributes(_Coroutine coroutine);
external void Coroutine_setAttributes(_Coroutine coroutine, int attributes);

external _Coroutine? Coroutine_getCaller(_Coroutine coroutine);
external void Coroutine_setCaller(_Coroutine coroutine, _Coroutine caller);

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

class Fiber {
  final int _index;

  late String _name;
  late int _size;
  late _Coroutine _coroutine;
  late void Function() _entry;
  late Object _argument;
  late _FiberProcessor _processor;
  late Fiber _scheduler;
  late Fiber _toProcessorNext;
  late Fiber _toProcessorPrevious;

  Fiber(this._index);

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
    if (child.state.disposed) {
      _pool.free(child.index);
    }
    return child;
  }

  @pragma("vm:prefer-inline")
  static void fork(Fiber callee) {
    final caller = Fiber.current;

    assert(callee.state.created || callee.state.finished);

    Coroutine_setCaller(callee._coroutine, caller._coroutine);

    final callerAttributes = Coroutine_getAttributes(caller._coroutine);
    Coroutine_setAttributes(caller._coroutine, (callerAttributes & ~_kFiberRunning) | _kFiberSuspended);

    final calleeAttributes = Coroutine_getAttributes(callee._coroutine);
    Coroutine_setAttributes(callee._coroutine, (calleeAttributes & ~_kFiberCreated & ~_kFiberFinished) | _kFiberRunning);

    Coroutine_fork(caller._coroutine, callee._coroutine);
  }

  @pragma("vm:prefer-inline")
  static void suspend() {
    final currentFiber = Fiber.current;
    final calleeCoroutine = Coroutine_getCaller(currentFiber._coroutine)!;
    Coroutine_setCaller(currentFiber._coroutine, currentFiber._scheduler._coroutine);
    Coroutine_transfer(currentFiber._coroutine, calleeCoroutine);
  }

  @pragma("vm:never-inline")
  static Fiber get current {
    final current = Coroutine_current();
    assert(current != null);
    return _pool.get(Coroutine_getOwner(current!));
  }

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
  int get index => _index;

  @pragma("vm:prefer-inline")
  int get size => _size;

  @pragma("vm:prefer-inline")
  String get name => _name;

  @pragma("vm:prefer-inline")
  FiberState get state => FiberState(Coroutine_getAttributes(_coroutine));

  @pragma("vm:prefer-inline")
  FiberAttributes get attributes => FiberAttributes(Coroutine_getAttributes(_coroutine));

  @pragma("vm:prefer-inline")
  FiberArgument get argument => FiberArgument(_argument);

  @pragma("vm:prefer-inline")
  void _initialize({
    required String name,
    required int size,
    required _Coroutine coroutine,
    required void Function() entry,
    required _FiberProcessor processor,
    Object? argument,
    Fiber? scheduler,
  }) {
    this._name = name;
    this._size = size;
    this._coroutine = coroutine;
    this._entry = entry;
    this._processor = processor!;
    if (argument != null) this._argument = argument!;
    if (scheduler != null) this._scheduler = scheduler!;
  }

  @pragma("vm:never-inline")
  static void _run() => Fiber.current._entry();
}