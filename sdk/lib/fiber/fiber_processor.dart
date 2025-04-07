part of dart.fiber;

extension type _FiberProcessorLink(Fiber _fiber) {
  @pragma("vm:prefer-inline")
  static void _create(Fiber fiber) {
    fiber._toProcessorNext = fiber;
    fiber._toProcessorPrevious = fiber;
  }

  @pragma("vm:prefer-inline")
  _FiberProcessorLink get _previous => _FiberProcessorLink(_fiber._toProcessorPrevious);

  @pragma("vm:prefer-inline")
  set _previous(_FiberProcessorLink value) => _fiber._toProcessorPrevious = value._fiber;

  @pragma("vm:prefer-inline")
  _FiberProcessorLink get _next => _FiberProcessorLink(_fiber._toProcessorNext);

  @pragma("vm:prefer-inline")
  set _next(_FiberProcessorLink value) => _fiber._toProcessorNext = value._fiber;

  @pragma("vm:prefer-inline")
  bool get _isEmpty => identical(_next._fiber, _previous._fiber) && identical(_next._fiber, _fiber);

  @pragma("vm:prefer-inline")
  void _stealTail(_FiberProcessorLink item) {
    item._previous._next = item._next;
    item._next._previous = item._previous;
    item._next = _FiberProcessorLink(_fiber);
    item._previous = _previous;
    item._previous._next = item;
    item._next._previous = item;
  }

  @pragma("vm:prefer-inline")
  _FiberProcessorLink _removeHead() {
    final shift = _next;
    _next = shift._next;
    shift._next._previous = _FiberProcessorLink(_fiber);
    shift._next = shift._previous = shift;
    return shift;
  }

  @pragma("vm:prefer-inline")
  void _remove(_FiberProcessorLink link) {
  	link._previous._next = link._next;
  	link._next._previous = link._previous;
    link._fiber._toProcessorNext = link._fiber;
    link._fiber._toProcessorPrevious = link._fiber;
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
    Coroutine_initialize(_scheduler._coroutine);
    _pool.clear();
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
    final main = scheduled._removeHead()._fiber;
    Fiber.fork(main);
    if (scheduled._isEmpty) return;
    for (;;) {
      var last = scheduled._removeHead();
      var first = last;
      while (!scheduled._isEmpty) {
        final caller = scheduled._removeHead();
        Coroutine_setCaller(last._fiber._coroutine, caller._fiber._coroutine);
        last = caller;
      }
      Coroutine_setCaller(last._fiber._coroutine, scheduler._coroutine);
      Coroutine_transfer(scheduler._coroutine, first._fiber._coroutine);
      if (first._fiber.state.disposed) {
        _pool.free(first._fiber.index);
      }
      if (scheduled._isEmpty) return;
    }
  }

  @pragma("vm:never-inline")
  static void _loopInfinite() {
    final scheduler = Fiber.current;
    final processor = scheduler._processor;
    final scheduled = processor._scheduled;
    final idle = processor._idle!;
    final main = scheduled._removeHead()._fiber;
    Fiber.fork(main);
    if (scheduled._isEmpty) {
      idle();
      if (scheduled._isEmpty) throw StateError("There are no scheduled fibers after idle");
    }
    for (;;) {
      var last = scheduled._removeHead();
      var first = last;
      while (!scheduled._isEmpty) {
        final caller = scheduled._removeHead();
        Coroutine_setCaller(last._fiber._coroutine, caller._fiber._coroutine);
        last = caller;
      }
      Coroutine_setCaller(last._fiber._coroutine, scheduler._coroutine);
      Coroutine_transfer(scheduler._coroutine, first._fiber._coroutine);
      if (first._fiber.state.disposed) {
        _pool.free(first._fiber.index);
      }
      if (scheduled._isEmpty) {
        idle();
        if (scheduled._isEmpty) throw StateError("There are no scheduled fibers after idle");
      }
    }
  }

  @pragma("vm:prefer-inline")
  void _schedule(Fiber fiber) => _scheduled._stealTail(_FiberProcessorLink(fiber));
}
