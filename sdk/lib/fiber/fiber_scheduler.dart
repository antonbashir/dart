part of dart.fiber;

class FiberScheduler {
  late _FiberLink _all;
  late _FiberLink _ready;
  late _FiberLink _finished;
  late Fiber _scheduler;
  late Fiber _main;

  FiberScheduler() {
    _all = _FiberLink();
    _ready = _FiberLink();
    _finished = _FiberLink();
    _scheduler = Fiber._scheduler(this, _loop);
  }

  @pragma("vm:prefer-inline")
  void start() {}

  @pragma("vm:never-inline")
  static void _loop() {
    final scheduler = Fiber.current().arguments[0] as FiberScheduler;
    scheduler._scheduleReady();
  }

  void _schedule(Fiber fiber) {

  }

  void _scheduleReady() {
    
  }
}
