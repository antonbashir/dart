import 'dart:fiber';
import 'dart:async';
import 'package:expect/expect.dart';

var testGlobalStateValue = "";
void testGlobalStateMain() {
  testGlobalStateValue = "";
  testGlobalStateValue += "main -> ";
  Fiber.schedule(Fiber.current());
  Fiber.spawn(testGlobalStateChild);
  testGlobalStateValue += "main -> ";
  Fiber.reschedule();
  Expect.equals("main -> child -> main -> child", testGlobalStateValue);
}

void testGlobalStateChild() {
  testGlobalStateValue += "child -> ";
  Fiber.reschedule();
  testGlobalStateValue += "child";
}

void testGlobalState() {
  Fiber.launch(testGlobalStateMain, terminate: true);
}
