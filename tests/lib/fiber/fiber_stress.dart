import 'dart:fiber';
import 'dart:async';
import 'package:expect/expect.dart';

final mainFiber = Fiber.main(entry: mainEntry);
final childFiber = Fiber.child(entry: childEntry, name: "child");

var commonState = "";

void main() {
  final iterations = 3;
  final timeout = Duration(minutes: 5);
  for (var i = 0; i < iterations; i++) {
    final sw = Stopwatch();
    sw.start();
    while (sw.elapsed.inMilliseconds < timeout.inMilliseconds) {
      Fiber.idle();
      commonState = "";
      mainFiber.start();
    }
    sw.stop();
  }
}

void mainEntry() {
  commonState += "main -> ";
  Fiber.spawn(childFiber);
  commonState += "main -> ";
  Fiber.suspend();
  Expect.equals("main -> child -> main -> child", commonState);
}

void childEntry() {
  commonState += "child -> ";
  Fiber.suspend();
  commonState += "child";
}
