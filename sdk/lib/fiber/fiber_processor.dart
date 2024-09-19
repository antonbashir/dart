part of dart.fiber;

class FiberProcessor {
  late _FiberLink _created;
  late _FiberLink _scheduled;
  late _FiberLink _finished;

  late Fiber _scheduler;
  late Fiber _main;

  final void Function() idle;
  static void _defaultIdle() => throw StateError("There are no scheduled fibers and FiberProcessor idle function is not defined");

  FiberProcessor({this.idle = _defaultIdle}) {
    _created = _FiberLink();
    _scheduled = _FiberLink();
    _finished = _FiberLink();
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
    final created = processor._created;
    final finished = processor._finished;
    final main = scheduled.removeHead()._value;
    main._caller = scheduler;
    _Coroutine._fork(scheduler, main);
    for (;;) {
      if (!scheduled.isEmpty) {
        Fiber first, last = scheduled.removeHead()._value;
        while (!scheduled.isEmpty) {
          last._caller = scheduled.removeHead()._value;
          last = Fiber(last._caller!);
        }
        last._caller = scheduler;
        first._attributes = (first._attributes & ~_kFiberScheduled) | _kFiberRunning;
        _Coroutine._transfer(scheduler, first);
        continue;
      }
      if (created.isEmpty) {
        return;
      }
      processor.idle();
    }
  }

  void _register(Fiber fiber) {
    //_created.addHead(fiber._schedulerStateLink);
  }

  void _schedule(Fiber fiber) {
    fiber._attributes = (fiber._attributes & ~_kFiberCreated & ~_kFiberSuspended) | _kFiberScheduled;
    //_scheduled.stealTail(fiber._schedulerReadyLink);
  }

  void _finalize(Fiber fiber) {
    //_finished.stealHead(fiber._schedulerStateLink);
  }
}
