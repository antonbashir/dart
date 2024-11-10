import 'dart:fiber';
import 'dart:async';
import 'package:expect/expect.dart';

final tests = [
  testIdleException,
  testMainException,
  testChildException,
  testChildSuspend,
  testMainSuspend,
];

class _FiberException implements Exception {
  final String message;
  const _FiberException(this.message);
}

void testIdleException() {
  Expect.throws<StateError>(
    () => Fiber.launch(() => Fiber.spawn(() => Fiber.reschedule()), idle: () => throw StateError("Empty idle")),
    (error) => error.message == "Empty idle",
  );
}

void testMainException() {
  Expect.throws<_FiberException>(
    () => Fiber.launch(() => throw _FiberException("main")),
    (e) => e.message == "main",
  );
}

void testChildException() {
  Expect.throws<_FiberException>(
    () => Fiber.launch(() => Fiber.spawn(() => throw _FiberException("child"))),
    (e) => e.message == "child",
  );

  Fiber.launch(
    () => Expect.throws<_FiberException>(
      () => Fiber.spawn(() => throw _FiberException("child")),
      (e) => e.message == "child",
    ),
  );
}

void testChildSuspend() {
  Expect.throws<_FiberException>(
    () => Fiber.launch(
      () {
        Fiber.spawn(Fiber.reschedule);
        throw _FiberException("main");
        Fiber.reschedule();
      },
    ),
    (e) => e.message == "main",
  );

  Fiber.launch(
    () => Expect.throws<_FiberException>(
      () {
        Fiber.spawn(Fiber.reschedule);
        throw _FiberException("main");
        Fiber.reschedule();
      },
      (e) => e.message == "main",
    ),
  );
}

void testMainSuspend() {
  Expect.throws<_FiberException>(
    () {
      Fiber.launch(() {
        Fiber.spawn(() {
          Fiber.reschedule();
          throw _FiberException("child");
        });
        Fiber.reschedule();
      });
    },
    (e) => e.message == "child",
  );

  Fiber.launch(
    () {
      Expect.throws<_FiberException>(
        () {
          Fiber.spawn(() {
            Fiber.reschedule();
            throw _FiberException("child");
          });
          Fiber.reschedule();
        },
        (e) => e.message == "child",
      );
    },
  );
}
