part of dart.fiber;

class FiberProcessor {
  late final void Function() _idle;
  late final _FiberLink _scheduled;
  late final Fiber _scheduler;
  late final void Function() _entry;
  late final bool _terminate;

  var _running = false;
  bool get running => _running;

  static void _defaultIdle() => throw StateError("There are no scheduled fibers and FiberProcessor idle function is not defined");

  FiberProcessor({void Function()? idle}) {
    _idle = idle ?? _defaultIdle;
    _scheduler = _FiberFactory.scheduler(this);
    _scheduled = _FiberLink(_scheduler);
  }

  void process(
    void Function() entry, {
    List arguments = const [],
    int size = _kDefaultStackSize,
    bool persistent = false,
    bool terminate = false,
  }) {
    if (_running) throw StateError("FiberProcessor is running");
    _terminate = terminate;
    _entry = entry;
    final main = _FiberFactory.main(
      this,
      _main,
      arguments: arguments,
      persistent: persistent,
      size: size,
    );
    _schedule(main);
    _running = true;
    _Coroutine._initialize(_scheduler);
    _running = false;
  }

  @pragma("vm:never-inline")
  static void _main() {
    final main = Fiber.current();
    final processor = main._processor;
    processor._entry();
    if (processor._terminate && processor._running) Fiber.terminate();
  }

  @pragma("vm:never-inline")
  static void _loop() {
    final scheduler = Fiber.current();
    final processor = scheduler._processor;
    final scheduled = processor._scheduled;
    final main = scheduled.removeHead()._value;
    final idle = processor._idle;
    main._caller = scheduler;
    _Coroutine._fork(scheduler, main);
    if (scheduled.isEmpty || !processor._running) return;
    for (;;) {
      while (scheduled.isEmpty) {
        idle();
        if (!processor._running) return;
      }
      Fiber last = scheduled.removeHead()._value;
      Fiber first = last;
      while (!scheduled.isEmpty) {
        last._caller = scheduled.removeHead()._value;
        last = Fiber(last._caller!);
      }
      last._caller = scheduler;
      first._attributes &= ~_kFiberSuspended;
      first._attributes |= _kFiberRunning;
      _Coroutine._transfer(scheduler, first);
      if (!processor._running) return;
    }
  }

  @pragma("vm:prefer-inline")
  void _stop() => _running = false;

  @pragma("vm:prefer-inline")
  void _schedule(Fiber fiber) => _scheduled.stealTail(fiber._toProcessor as _FiberLink);
}
