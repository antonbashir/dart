import 'dart:fiber';

final mainFiber = Fiber.main(entry: mainEntry);
final childFiber = Fiber.child(entry: childEntry, name: "child");

var counter = 10000000;
var value = 10000000;

void main() {
  mainFiber.start();
}

void mainEntry() {
  final sw = Stopwatch();
  sw.start();
  Fiber.spawn(childFiber);
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
