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
