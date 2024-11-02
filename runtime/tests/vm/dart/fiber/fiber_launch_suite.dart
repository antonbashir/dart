import 'dart:fiber';
import 'dart:async';
import 'package:expect/expect.dart';

final tests = <Function>[
  testEmpty,
  testIdle,
  testTerminated,
  testFunction,
  testGlobalState,
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
    print(Fiber.current().arguments.value);
    print(Fiber.current().arguments.value[0]);
    print(Fiber.current().arguments.value[0][0]);
    final arguments = Fiber.current().arguments.value[0][0] as String;
    print(arguments);
    Expect.equals("argument", arguments);
  }

  Fiber.launch(entry, arguments: <String>["argument"], terminate: true);
}

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
