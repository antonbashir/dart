import 'dart:fiber';
import 'dart:async';
import 'package:expect/expect.dart';

final mainFiber = Fiber.main(mainEntry, managed: true);

var commonState = "";

void main() {
  final iterations = 1000000;
  final timeout = Duration(minutes: 15);
  for (var i = 0; i < iterations; i++) {
    final sw = Stopwatch();
    sw.start();
    while (sw.elapsed.inMilliseconds < timeout.inMilliseconds) {
      commonState = "";
      mainFiber.start();
    }
    sw.stop();
  }
}

void mainEntry() {
  commonState += "main -> ";
  Fiber.spawn(childEntry);
  commonState += "main -> ";
  Fiber.suspend();
  Expect.equals("main -> child -> main -> child", commonState);
}

void childEntry() {
  commonState += "child -> ";
  Fiber.suspend();
  commonState += "child";
}
