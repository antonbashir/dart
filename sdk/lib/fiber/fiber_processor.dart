part of dart.fiber;

class FiberProcessor {
  late _FiberLink _created;
  late _FiberLink _scheduled;
  late _FiberLink _finished;

  late Fiber _scheduler;
  late Fiber _main;

  final void Function() idle;
  static void _defaultIdle() => throw StateError("message");

  FiberProcessor({this.idle = _defaultIdle}) {
    _created = _FiberLink();
    _scheduled = _FiberLink();
    _finished = _FiberLink();
    _scheduler = _FiberFactory.scheduler(this);
  }

  @pragma("vm:prefer-inline")
  void process(
    void Function() entry, {
    List arguments = const [],
    int size = _kDefaultStackSize,
    bool persistent = false,
    bool run = true,
  }) {
    final main = _FiberFactory.main(
      this,
      entry,
      arguments: arguments,
      persistent: persistent,
      size: size,
      run: run,
    );
    _register(main);
    _schedule(main);
    _Coroutine._initialize(_scheduler);
  }

  @pragma("vm:never-inline")
  static void _loop() {
    final processor = Fiber.current()._processor!;
    final scheduled = processor._scheduled;
    final created = processor._created;
    final finished = processor._finished;
    for (;;) {
      if (created.isEmpty) {
        return;
      }
      if (scheduled.isEmpty) {
        processor.idle();
        continue;
      }
      var first, last = scheduled.removeHead()._value._coroutine;
      while (!scheduled.isEmpty) {
        last._caller = scheduled.removeHead()._value._coroutine;
        last = last._caller!;
      }
      last._caller = Fiber.current();
      _Coroutine._transfer(Fiber.current(), first);
    }
  }

  void _register(Fiber fiber) {
    //_created.addHead(fiber._schedulerStateLink);
  }

  void _schedule(Fiber fiber) {
    //_scheduled.stealTail(fiber._schedulerReadyLink);
  }

  void _finalize(Fiber fiber) {
    //_finished.stealHead(fiber._schedulerStateLink);
  }
}
