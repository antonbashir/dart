import 'dart:fiber';
import 'dart:async';
import 'package:expect/expect.dart';

final tests = [
  testEmpty,
  testTerminated,
  testFunction,
  testClosure,
  testFork,
  testForks,
];

void testEmpty() {
  final fiber = Fiber.launch(() {
    Expect.equals(Fiber.current.state.kind, FiberStateKind.running);
  });
  Expect.equals(fiber.state.kind, FiberStateKind.disposed);
}

void testTerminated() {
  final fiber = Fiber.launch(() {
    final child = Fiber.spawn(() => Fiber.reschedule());
    Expect.equals(child.state.kind, FiberStateKind.suspended);
    Fiber.reschedule();
    Expect.equals(child.state.kind, FiberStateKind.disposed);
  });
  Expect.equals(fiber.state.kind, FiberStateKind.disposed);
}

void testFunction() {
  void entry() {
    Expect.equals("argument", Fiber.current.argument.positioned(0));
  }

  Fiber.launch(entry, argument: ["argument"]);
}

void testClosure() {
  Fiber.launch(
    () => Expect.equals("argument", Fiber.current.argument.positioned(0)),
    argument: ["argument"],
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

  Fiber.launch(main, argument: ["main"]);
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

  Fiber.launch(main, argument: ["main"]);
}
