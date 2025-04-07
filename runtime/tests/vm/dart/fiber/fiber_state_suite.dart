import 'dart:fiber';
import 'package:expect/expect.dart';

final tests = [
  testProcessor,
];

void testProcessor() {
  Expect.isTrue(Fiber.launch(() {}).state.disposed);
  Expect.isTrue(Fiber.launch(() => Fiber.spawn(Fiber.reschedule)).state.disposed);

  Expect.throws<StateError>(
    () => Fiber.launch(() => Fiber.spawn(Fiber.suspend), idle: () {}),
    (error) => error.message == "There are no scheduled fibers after idle",
  );

  Fiber.launch(() {
    final fibers = <Fiber, int>{};
    var next = 0;
    fibers[Fiber.child(() {
      Fiber.reschedule();
      Expect.equals(next++, fibers[Fiber.current]);
    })] = 0;
    fibers[Fiber.child(() {
      Fiber.reschedule();
      Expect.equals(next++, fibers[Fiber.current]);
    })] = 1;
    fibers[Fiber.child(() {
      Fiber.reschedule();
      Expect.equals(next++, fibers[Fiber.current]);
    })] = 2;
    fibers[Fiber.child(() {
      Fiber.reschedule();
      Expect.equals(next++, fibers[Fiber.current]);
    })] = 3;
    fibers[Fiber.child(() {
      Fiber.reschedule();
      Expect.equals(next++, fibers[Fiber.current]);
    })] = 4;

    fibers.forEach((fiber, value) => Fiber.fork(fiber));

    Fiber.suspend();
    Fiber.suspend();
    Fiber.suspend();
    Fiber.suspend();
    Fiber.suspend();

    Expect.equals(5, next);
  });
}
