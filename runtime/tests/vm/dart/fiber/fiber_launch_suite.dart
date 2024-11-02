import 'dart:fiber';
import 'dart:async';
import 'package:expect/expect.dart';

final tests = <Function>[
  testEmpty,
  testIdle,
  testTerminated,
  testFunction,
];

void testEmpty() {
  Fiber.launch(() {});
}

void testIdle() {
  Expect.throws(
    () => Fiber.launch(() => Fiber.spawn(() => Fiber.reschedule())),
    (error) => error is StateError && error.message == "There are no scheduled fibers and FiberProcessor idle function is not defined",
  );
}

void testTerminated() {
  Fiber.launch(() => Fiber.spawn(() => Fiber.reschedule()), terminate: true);
}

void testFunction() {
  void entry() {
    Expect.equals("argument", Fiber.current().arguments[0] as String);
  }

  Fiber.launch(entry, arguments: ["argument"], terminate: true);
}

var testBaseGlobalState = "";
void testBaseMainEntry() {
  testBaseGlobalState = "";
  testBaseGlobalState += "main -> ";
  Fiber.schedule(Fiber.current());
  Fiber.spawn(testBaseChildEntry);
  testBaseGlobalState += "main -> ";
  Fiber.reschedule();
  Expect.equals("main -> child -> main -> child", testBaseGlobalState);
}

void testBaseChildEntry() {
  testBaseGlobalState += "child -> ";
  Fiber.reschedule();
  testBaseGlobalState += "child";
}

void testBase() {
  Fiber.launch(testBaseMainEntry, terminate: true);
}
