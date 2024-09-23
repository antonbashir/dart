part of dart.fiber;

class _FiberProcessor {
  late final void Function() _idle;
  late final _FiberLink _scheduled;
  late final Fiber _scheduler;

  late void Function() _entry;
  late bool _terminate;

  var _running = false;
  bool get running => _running;

  static void _defaultIdle() => throw StateError("There are no scheduled fibers and FiberProcessor idle function is not defined");

  _FiberProcessor({void Function()? idle}) {
    _idle = idle ?? _defaultIdle;
    _scheduler = _FiberFactory._scheduler(this);
    _scheduled = _FiberLink(_scheduler);
  }

  void _process(
    void Function() entry, {
    List arguments = const [],
    int size = _kDefaultStackSize,
    bool terminate = false,
  }) {
    if (_running) throw StateError("FiberProcessor is running");
    _terminate = terminate;
    _entry = entry;
    _schedule(_FiberFactory._main(this, _main, arguments: arguments, size: size));
    _running = true;
    _Coroutine._initialize(_scheduler);
    _running = false;
  }

  @pragma("vm:never-inline")
  static void _main() {
    final processor = Fiber.current()._processor;
    processor._entry();
    if (processor._terminate && processor._running) Fiber.terminate();
  }

  @pragma("vm:never-inline")
  static void _loop() {
    final scheduler = Fiber.current();
    final processor = scheduler._processor;
    final scheduled = processor._scheduled;
    final idle = processor._idle;
    Fiber.fork(scheduled._removeHead()._value);
    if (scheduled._isEmpty || !processor._running) return;
    for (;;) {
      var last = scheduled._removeHead()._value;
      var first = last;
      while (!scheduled._isEmpty) {
        last._caller = scheduled._removeHead()._value;
        last = Fiber(last._caller!);
      }
      last._caller = scheduler;
      scheduler._attributes = (scheduler._attributes & ~_kFiberRunning) | _kFiberSuspended;
      first._attributes = (first._attributes & ~_kFiberSuspended) | _kFiberRunning;
      _Coroutine._transfer(scheduler, first);
      if (processor._running && scheduled._isEmpty) {
        idle();
        if (!processor._running) return;
        if (scheduled._isEmpty) throw StateError("There are no scheduled fibers after idle");
        continue;
      }
    }
  }

  @pragma("vm:prefer-inline")
  void _stop() => _running = false;

  @pragma("vm:prefer-inline")
  void _schedule(Fiber fiber) => _scheduled._stealTail(fiber._toProcessor as _FiberLink);
}
