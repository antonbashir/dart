part of dart.fiber;

class FiberProcessor {
  late _FiberLink _scheduled;

  late Fiber _scheduler;
  late Fiber _main;

  var _running = false;

  final void Function() idle;
  static void _defaultIdle() => throw StateError("There are no scheduled fibers and FiberProcessor idle function is not defined");

  FiberProcessor({this.idle = _defaultIdle}) {
    _scheduled = _FiberLink();
    _scheduler = _FiberFactory.scheduler(this);
  }

  void process(
    void Function() entry, {
    List arguments = const [],
    int size = _kDefaultStackSize,
    bool persistent = false,
  }) {
    if (_running) throw StateError("FiberProcessor is running");
    final main = _FiberFactory.main(
      this,
      entry,
      arguments: arguments,
      persistent: persistent,
      size: size,
    );
    _schedule(main);
    _Coroutine._initialize(_scheduler);
  }

  void _terminate() {
    _running = false;
  }

  @pragma("vm:never-inline")
  static void _loop() {
    final scheduler = Fiber.current();
    final processor = scheduler._processor;
    final scheduled = processor._scheduled;
    final main = scheduled.removeHead()._value;
    processor._running = true;
    main._caller = scheduler;
    _Coroutine._fork(scheduler, main);
    if (scheduled.isEmpty || !processor._running) return;
    for (;;) {
      while (scheduled.isEmpty) {
        processor.idle();
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
  void _schedule(Fiber fiber) => _scheduled.stealTail(fiber._toProcessor as _FiberLink);
}
