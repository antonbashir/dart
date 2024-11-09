import 'dart:fiber';
import 'dart:async';
import 'package:expect/expect.dart';

final tests = [
  testEmpty,
  testIdle,
  testTerminated,
  testFunction,
  testClosure,
  testFork,
  testForks,
];

void testEmpty() {
  final fiber = Fiber.launch(() {
    Expect.isTrue(Fiber.current.state.running);
  });
  Expect.isTrue(fiber);
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
    Expect.equals("argument", Fiber.current.argument.positioned(0));
  }

  Fiber.launch(entry, argument: ["argument"], terminate: true);
}

void testClosure() {
  Fiber.launch(
    () => Expect.equals("argument", Fiber.current.argument.positioned(0)),
    argument: ["argument"],
    terminate: true,
  );
}

void testFork() {
  void child() {
    Expect.equals("child", Fiber.current.name);
    Expect.equals("child", Fiber.current.argument.positioned(0));
  }

  void main() {
    Expect.equals("main", Fiber.current.argument.positioned(0));
    Fiber.spawn(child, name: "child", argument: ["child"]);
  }

  Fiber.launch(main, argument: ["main"], terminate: true);
}

void testForks() {
  void child3() {
    Expect.equals("child3", Fiber.current.name);
    Expect.equals("child3", Fiber.current.argument.positioned(0));
  }

  void child2() {
    Expect.equals("child2", Fiber.current.name);
    Expect.equals("child2", Fiber.current.argument.positioned(0));
    Fiber.spawn(child3, name: "child3", argument: ["child3"]);
  }

  void child1() {
    Expect.equals("child1", Fiber.current.name);
    Expect.equals("child1", Fiber.current.argument.positioned(0));
    Fiber.spawn(child2, name: "child2", argument: ["child2"]);
  }

  void main() {
    Expect.equals("main", Fiber.current.argument.positioned(0));
    Fiber.spawn(child1, name: "child1", argument: ["child1"]);
  }

  Fiber.launch(main, argument: ["main"], terminate: true);
}
