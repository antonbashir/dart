import 'dart:fiber';

final mainFiber = Fiber.main(size: 1024 * 1024, entry: mainEntry);
final childFiber = Fiber.child(size: 1024 * 1024, entry: childEntry, name: "child");

var counter = 10000000;
var value = 10000000;

void main() {
  mainFiber.start();
}

void mainEntry() {
  final sw = Stopwatch();
  sw.start();
  mainFiber.fork(childFiber);
  while (--value > 0) {
    mainFiber.transfer(childFiber);
  }
  sw.stop();
  print(sw.elapsedMicroseconds / counter);
}

void childEntry() {
  while (--value > 0) {
    childFiber.transfer(mainFiber);
  }
}
