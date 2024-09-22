import 'dart:fiber';

var iterations = 50000;
var fibers = 100;

void main() {
  Fiber.launch(benchmark, terminate: true);
}

void benchmark() {
  final jobs = <Fiber>[];
  for (var i = 0; i < fibers; i++) {
    jobs.add(Fiber.child(scheduling));
    Fiber.schedule(jobs[i]);
  }
  final sw = Stopwatch();
  sw.start();
  for (var i = 0; i < fibers; i++) {
    while (!jobs[i].state.disposed) {
      Fiber.suspend();
    }
  }
  sw.stop();
  print("Latency per switch: ${sw.elapsedMicroseconds / (iterations * fibers)} [micros]");
}

void scheduling() {
  for (var i = 0; i < iterations; i++) {
    Fiber.reschedule();
  }
}
