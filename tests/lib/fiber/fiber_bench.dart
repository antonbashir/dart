import 'dart:fiber';


var counter = 10000000;
var value = 10000000;

void main() {
  FiberProcessor().process(mainEntry);
}

void mainEntry() {
  final sw = Stopwatch();
  sw.start();
  Fiber.spawn(childEntry);
  while (--value > 0) {
    Fiber.suspend();
  }
  sw.stop();
  print("Latency per switch: ${sw.elapsedMicroseconds / counter} [micros]");
}

void childEntry() {
  while (--value > 0) {
    Fiber.suspend();
  }
}
