part of dart.fiber;

extension type _FiberProcessorLink(_Coroutine _coroutine) {
  @pragma("vm:prefer-inline")
  static void _create(_Coroutine coroutine) {
    coroutine._toProcessorNext = coroutine;
    coroutine._toProcessorPrevious = coroutine;
  }

  @pragma("vm:prefer-inline")
  _FiberProcessorLink get _previous => _FiberProcessorLink(_coroutine._toProcessorPrevious);

  @pragma("vm:prefer-inline")
  set _previous(_FiberProcessorLink value) => _coroutine._toProcessorPrevious = value._coroutine;

  @pragma("vm:prefer-inline")
  _FiberProcessorLink get _next => _FiberProcessorLink(_coroutine._toProcessorNext);

  @pragma("vm:prefer-inline")
  set _next(_FiberProcessorLink value) => _coroutine._toProcessorNext = value._coroutine;

  @pragma("vm:prefer-inline")
  bool get _isEmpty => identical(_next._coroutine, _previous._coroutine) && identical(_next._coroutine, _coroutine);

  @pragma("vm:prefer-inline")
  void _stealTail(_FiberProcessorLink item) {
    item._previous._next = item._next;
    item._next._previous = item._previous;
    item._next = _FiberProcessorLink(_coroutine);
    item._previous = _previous;
    item._previous._next = item;
    item._next._previous = item;
  }

  @pragma("vm:prefer-inline")
  _FiberProcessorLink _removeHead() {
    final shift = _next;
    _next = shift._next;
    shift._next._previous = _FiberProcessorLink(_coroutine);
    shift._next = shift._previous = shift;
    return shift;
  }
}

class _FiberProcessor {
  late final void Function() _idle;
  late final _FiberProcessorLink _scheduled;
  late final Fiber _scheduler;

  late void Function() _entry;
  late bool _terminate;

  var _running = false;
  bool get running => _running;

  static void _defaultIdle() => throw StateError("There are no scheduled fibers and FiberProcessor idle function is not defined");

  _FiberProcessor({void Function()? idle}) {
    _idle = idle ?? _defaultIdle;
    _scheduler = _FiberFactory._scheduler(this);
    _scheduled = _FiberProcessorLink(_scheduler);
    _FiberProcessorLink._create(_scheduler);
    print("_FiberProcessor constructor");
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
    print("_Coroutine._initialize start");
    _Coroutine._initialize(_scheduler);
    print("_Coroutine._initialize finish");
    _running = false;
  }

  @pragma("vm:never-inline")
  static void _main() {
    final processor = Fiber.current()._processor;
    print("main entry run");
    processor._entry();
    print("main entry run done");
    if (processor._terminate && processor._running) Fiber.terminate();
  }

  @pragma("vm:never-inline")
  static void _loop() {
    final scheduler = Fiber.current();
    final processor = scheduler._processor;
    final scheduled = processor._scheduled;
    final idle = processor._idle;
    print("main fork start");
    Fiber.fork(Fiber(scheduled._removeHead()._coroutine));
    print("main fork done");
    if (scheduled._isEmpty || !processor._running) return;
    for (;;) {
      var last = Fiber(scheduled._removeHead()._coroutine);
      var first = last;
      while (!scheduled._isEmpty) {
        last._caller = Fiber(scheduled._removeHead()._coroutine);
        last = Fiber(last._caller);
      }
      last._caller = scheduler;
      scheduler._attributes = (scheduler._attributes & ~_kFiberRunning) | _kFiberSuspended;
      first._attributes = (first._attributes & ~_kFiberSuspended) | _kFiberRunning;
      print("transfer to: ${first.name}");
      _Coroutine._transfer(scheduler, first);
      if (processor._running && scheduled._isEmpty) {
        idle();
        if (!processor._running) {
          print("procesor is not running, return");
          return;
        }
        if (scheduled._isEmpty) throw StateError("There are no scheduled fibers after idle");
        print("procesor is running, continue");
        continue;
      }
    }
  }

  @pragma("vm:prefer-inline")
  void _stop() => _running = false;

  @pragma("vm:prefer-inline")
  void _schedule(Fiber fiber) {
    print("_schedule: ${fiber.name}");
    _scheduled._stealTail(_FiberProcessorLink(fiber._coroutine));
  }
}
