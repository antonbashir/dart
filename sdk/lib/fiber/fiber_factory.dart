part of dart.fiber;

class _FiberFactory {
  @pragma("vm:prefer-inline")
  static Fiber _scheduler(_FiberProcessor processor) {
    final fiber = _pool.allocate();
    final coroutine = Coroutine_create(_kSchedulerStackSize, fiber._index, fiber, _kFiberCreated, Fiber._run)!;
    fiber._initialize(
      name: _kSchedulerFiber,
      size: _kSchedulerStackSize,
      coroutine: coroutine,
      entry: processor._idle == null ? _FiberProcessor._loopFinite : _FiberProcessor._loopInfinite,
      processor: processor,
    );
    return fiber;
  }

  @pragma("vm:prefer-inline")
  static Fiber _main(
    _FiberProcessor processor,
    void Function() entry, {
    Object? argument = null,
    int size = _kDefaultStackSize,
  }) {
    final fiber = _pool.allocate();
    final coroutine = Coroutine_create(size, fiber._index, fiber, _kFiberCreated, Fiber._run)!;
    fiber._initialize(
      name: _kMainFiber,
      size: _kDefaultStackSize,
      coroutine: coroutine,
      entry: entry,
      processor: processor,
      scheduler: processor._scheduler,
      argument: argument,
    );
    _FiberProcessorLink._create(fiber);
    return fiber;
  }

  @pragma("vm:prefer-inline")
  static Fiber _child(
    void Function() entry, {
    Object? argument = null,
    int size = _kDefaultStackSize,
    bool persistent = false,
    String? name,
  }) {
    final current = Fiber.current;
    final fiber = _pool.allocate();
    final coroutine = Coroutine_create(size, fiber._index, fiber, FiberAttributes._calculate(persistent: persistent).value, Fiber._run)!;
    fiber._initialize(
      name: name ?? entry.toString(),
      size: size,
      coroutine: coroutine,
      entry: entry,
      processor: current._processor,
      scheduler: current._scheduler,
      argument: argument,
    );
    _FiberProcessorLink._create(fiber);
    return fiber;
  }
}
