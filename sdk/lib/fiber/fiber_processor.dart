part of dart.fiber;

class FiberProcessor {
  late _FiberLink _scheduled;

  late Fiber _scheduler;
  late Fiber _main;

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

  @pragma("vm:never-inline")
  static void _loop() {
    final scheduler = Fiber.current();
    final processor = scheduler._processor;
    final scheduled = processor._scheduled;
    final main = scheduled.removeHead()._value;
    main._caller = scheduler;
    _Coroutine._fork(scheduler, main);
    for (;;) {
      if (!scheduled.isEmpty) {
        Fiber last = scheduled.removeHead()._value;
        Fiber first = last;
        while (!scheduled.isEmpty) {
          last._caller = scheduled.removeHead()._value;
          last = Fiber(last._caller!);
        }
        last._caller = scheduler;
        first._attributes = (first._attributes & ~_kFiberScheduled) | _kFiberRunning;
        _Coroutine._transfer(scheduler, first);
        continue;
      }
      processor.idle();
    }
  }

  void _schedule(Fiber fiber) {
    fiber._attributes = (fiber._attributes & ~_kFiberCreated & ~_kFiberSuspended) | _kFiberScheduled;
    _scheduled.stealTail(fiber._toProcessor as _FiberLink);
  }
}
