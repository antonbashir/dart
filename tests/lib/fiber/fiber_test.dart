import 'dart:fiber';
import 'dart:async';
import 'package:expect/expect.dart';

final mainFiber = Fiber.main(entry: mainEntry);
final childFiber = Fiber.child(entry: childEntry, name: "child");

var commonState = "";

void main() {
  mainFiber.start();
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
