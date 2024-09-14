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
  }

  void schedule(Fiber fiber) {

  }

  void scheduleList(_FiberLink list) {
    
  }
}
