part of dart.fiber;

class FiberScheduler {
  late _FiberLink _created;
  late _FiberLink _scheduled;
  late _FiberLink _finished;
  late Fiber _scheduler;
  late Fiber _main;

  FiberScheduler() {
    _created = _FiberLink();
    _scheduled = _FiberLink();
    _finished = _FiberLink();
    _scheduler = Fiber._scheduler(this, _loop);
  }

  @pragma("vm:prefer-inline")
  void start(
    void Function() entry, {
    List arguments = const [],
    int size = _kDefaultStackSize,
    bool persistent = false,
  }) {
    final main = Fiber._main(
      this,
      entry,
      arguments: arguments,
      persistent: persistent,
      size: size,
    );
    _register(main);
    _schedule(main);
    _Coroutine._initialize(_scheduler._coroutine);
  }

  @pragma("vm:never-inline")
  static void _loop() {
    final scheduler = Fiber.current().arguments[0] as FiberScheduler;
    final scheduled = scheduler._scheduled;
    final created = scheduler._created;
    final finished = scheduler._finished;
    for (;;) {
      if (created.isEmpty) {
        return;
      }
      if (scheduled.isEmpty) {
        continue;
      }
      var first, last = scheduled.removeHead()._value;
      while (!scheduled.isEmpty) {
        last._coroutine._caller = scheduled.removeHead()._value._coroutine;
        last = last._coroutine._caller!._owner;
      }
      last._coroutine._caller = Fiber.current()._coroutine;
      _Coroutine._transfer(Fiber.current()._coroutine, first);
    }
  }

  void _register(Fiber fiber) {
    _created.addHead(fiber._schedulerStateLink);
  }

  void _schedule(Fiber fiber) {
    _scheduled.stealTail(fiber._schedulerReadyLink);
  }

  void _finalize(Fiber fiber) {
    _finished.stealHead(fiber._schedulerStateLink);
  }
}
