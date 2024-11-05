part of dart.fiber;

class _FiberFactory {
  @pragma("vm:prefer-inline")
  static Fiber _scheduler(_FiberProcessor processor) {
    final coroutine = _Coroutine._(_kSchedulerStackSize, Fiber._run);
    coroutine._name = _kSchedulerFiber;
    coroutine._entry = _FiberProcessor._loop;
    coroutine._processor = processor;
    coroutine._attributes = _kFiberCreated;
    return Fiber(coroutine);
  }

  @pragma("vm:prefer-inline")
  static Fiber _main(
    _FiberProcessor processor,
    void Function() entry, {
    Object? argument = null,
    int size = _kDefaultStackSize,
  }) {
    final coroutine = _Coroutine._(size, Fiber._run);
    coroutine._name = _kMainFiber;
    coroutine._entry = entry;
    coroutine._processor = processor;
    coroutine._scheduler = processor._scheduler;
    _FiberProcessorLink._create(coroutine);
    if (argument != null) coroutine._argument = argument;
    coroutine._attributes = _kFiberCreated;
    return Fiber(coroutine);
  }

  @pragma("vm:prefer-inline")
  static Fiber _child(
    void Function() entry, {
    Object? argument = null,
    int size = _kDefaultStackSize,
    bool persistent = false,
    String? name,
  }) {
    final current = Fiber.current();
    final coroutine = _Coroutine._(size, Fiber._run);
    coroutine._name = name ?? entry.toString();
    coroutine._entry = entry;
    coroutine._processor = current._processor;
    coroutine._scheduler = current._scheduler;
    _FiberProcessorLink._create(coroutine);
    if (argument != null) coroutine._argument = argument;
    coroutine._attributes = FiberAttributes._calculate(persistent: persistent).value;
    return Fiber(coroutine);
  }
}
