import 'dart:fiber';

var iterations = 50000;
var fibers = 100;

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
  final sw = Stopwatch();
  sw.start();
  for (var i = 0; i < fibers; i++) {
    while (!jobs[i].state.disposed) {
      Fiber.reschedule();
    }
  }
  sw.stop();
  print("Latency per switch: ${sw.elapsedMicroseconds / (iterations * fibers)} [micros]");
}

void scheduling() {
  Fiber.suspend();
  for (var i = 0; i < iterations; i++) {
    Fiber.reschedule();
  }
}
