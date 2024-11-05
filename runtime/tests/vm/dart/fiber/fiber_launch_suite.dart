import 'dart:fiber';
import 'dart:async';
import 'package:expect/expect.dart';

final tests = [
  testEmpty,
  testIdle,
  testTerminated,
  testFunction,
  testFork,
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
    Expect.equals("argument", Fiber.current().argument.positioned(0));
  }

  Fiber.launch(entry, argument: ["argument"], terminate: true);
}

void testFork() {
  void child() {
    print(Fiber.current().argument.single() == null);
    Expect.equals("child", Fiber.current().argument.positioned(0));
  }

  void main() {
    Expect.equals("main", Fiber.current().argument.positioned(0));
    Fiber.spawn(child, argument: ["child"]);
  }

  Fiber.launch(main, argument: ["main"], terminate: true);
}
