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
  final void Function()? _idle;
  late final _FiberProcessorLink _scheduled;
  late final Fiber _scheduler;

  late void Function() _entry;

  var _running = false;
  bool get running => _running;

  _FiberProcessor(void Function()? idle) : _idle = idle;

  Fiber _process(
    void Function() entry, {
    int size = _kDefaultStackSize,
    Object? argument,
  }) {
    if (_running) throw StateError("FiberProcessor is running");
    _entry = entry;
    _scheduler = _FiberFactory._scheduler(this);
    _scheduled = _FiberProcessorLink(_scheduler);
    _FiberProcessorLink._create(_scheduler);
    final fiber = _FiberFactory._main(this, _main, argument: argument, size: size);
    _schedule(fiber);
    _running = true;
    _Coroutine._initialize(_scheduler);
    _running = false;
    return fiber;
  }

  @pragma("vm:never-inline")
  static void _main() {
    final processor = Fiber.current._processor;
    processor._entry();
    processor._running = processor._idle != null;
  }

  @pragma("vm:never-inline")
  static void _loopFinite() {
    final scheduler = Fiber.current;
    final processor = scheduler._processor;
    final scheduled = processor._scheduled;
    Fiber.fork(Fiber(scheduled._removeHead()._coroutine));
    if (scheduled._isEmpty) return;
    for (;;) {
      var last = Fiber(scheduled._removeHead()._coroutine);
      var first = last;
      while (!scheduled._isEmpty) {
        last._caller = Fiber(scheduled._removeHead()._coroutine);
        last = Fiber(last._caller);
      }
      last._caller = scheduler;
      _Coroutine._transfer(scheduler, first);
      if (scheduled._isEmpty) return;
    }
  }

  @pragma("vm:never-inline")
  static void _loopInfinite() {
    final scheduler = Fiber.current;
    final processor = scheduler._processor;
    final scheduled = processor._scheduled;
    final idle = processor._idle!;
    Fiber.fork(Fiber(scheduled._removeHead()._coroutine));
    if (scheduled._isEmpty) {
      idle();
      if (scheduled._isEmpty) throw StateError("There are no scheduled fibers after idle");
    }
    for (;;) {
      var last = Fiber(scheduled._removeHead()._coroutine);
      var first = last;
      while (!scheduled._isEmpty) {
        last._caller = Fiber(scheduled._removeHead()._coroutine);
        last = Fiber(last._caller);
      }
      last._caller = scheduler;
      _Coroutine._transfer(scheduler, first);
      if (scheduled._isEmpty) {
        idle();
        if (scheduled._isEmpty) throw StateError("There are no scheduled fibers after idle");
      }
    }
  }

  @pragma("vm:prefer-inline")
  void _schedule(Fiber fiber) => _scheduled._stealTail(_FiberProcessorLink(fiber._coroutine));
}
