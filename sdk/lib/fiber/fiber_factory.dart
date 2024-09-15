part of dart.fiber;

class _FiberFactory {
  @pragma("vm:prefer-inline")
  static Fiber scheduler(FiberProcessor processor) {
    final coroutine = _Coroutine._(_kSchedulerStackSize);
    coroutine._name = _kSchedulerFiber;
    coroutine._entry = FiberProcessor._loop;
    coroutine._processor = processor;
    coroutine._trampoline = Fiber._run;
    coroutine._arguments = [];
    coroutine._attributes = _kFiberAttributeNothing;
    return Fiber(coroutine);
  }

  @pragma("vm:prefer-inline")
  static Fiber main(
    FiberProcessor processor,
    void Function() entry, {
    List arguments = const [],
    int size = _kDefaultStackSize,
    bool persistent = false,
    bool run = true,
  }) {
    final coroutine = _Coroutine._(size);
    coroutine._name = _kSchedulerFiber;
    coroutine._entry = entry;
    coroutine._processor = processor;
    coroutine._scheduler = processor._scheduler;
    coroutine._trampoline = run ? Fiber._run : Fiber._defer;
    coroutine._arguments = arguments;
    coroutine._attributes = FiberAttributes._calculate(persistent: persistent).value;
    return Fiber(coroutine);
  }

  @pragma("vm:prefer-inline")
  static Fiber child(
    void Function() entry, {
    List arguments = const [],
    int size = _kDefaultStackSize,
    bool run = true,
    bool persistent = false,
    String? name,
  }) {
    final current = Fiber.current();
    final coroutine = _Coroutine._(size);
    coroutine._name = name ?? entry.toString();
    coroutine._entry = entry;
    coroutine._processor = current!._processor;
    coroutine._scheduler = current!._scheduler;
    coroutine._trampoline = run ? Fiber._run : Fiber._defer;
    coroutine._arguments = arguments;
    coroutine._attributes = FiberAttributes._calculate(persistent: persistent).value;
    return Fiber(coroutine);
  }
}
