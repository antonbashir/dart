import 'dart:fiber';

var iterations = 50000;
var fibers = 100;

var latency = 0.0;

void main() {
  Fiber.launch(benchmark, terminate: true);
}

void benchmark() {
  final jobs = <Fiber>[];
  for (var i = 0; i < fibers; i++) {
    Fiber.schedule(Fiber.current());
    jobs.add(Fiber.spawn(scheduling));
  }
  for (var i = 0; i < fibers; i++) {
    Fiber.schedule(jobs[i]);
  }
  for (var i = 0; i < fibers; i++) {
    while (!jobs[i].state.disposed) {
      Fiber.reschedule();
    }
  }
  print("Latency per switch: ${latency / fibers / (iterations * 4)} [micros]");
}

void scheduling() {
  Fiber.suspend();
  final sw = Stopwatch();
  sw.start();
  for (var i = 0; i < iterations; i++) {
    Fiber.reschedule();
  }
  sw.stop();
  latency += sw.elapsedMicroseconds;
}
