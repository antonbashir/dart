import 'dart:fiber';
import 'dart:async';
import 'package:expect/expect.dart';

void main() {
  _run(mainException: true);
  _run(childException: true);
  _run(childException: true, mainCatchChild: true);
  _run(childYield: true);
  _run(childYield: true, mainCatchChild: true);
}

class FiberException implements Exception {
  final String message;
  const FiberException(this.message);
}

void _run({mainException = false, childException = false, mainCatchChild = false, childYield = false, mainYield = false}) {
  print("_run: mainException = $mainException, childException = $childException, mainCatchChild = $mainCatchChild, childYield = $childYield, mainYield = $mainYield");
  if (mainYield) {
    final child = Fiber.child(() {
      Fiber.suspend();
      throw FiberException("child");
    }, name: "child");
    if (mainCatchChild) {
      final main = Fiber.main(
        () => Expect.equals(
          Expect.throws<FiberException>(
            () {
              Fiber.fork(child);
              Fiber.suspend();
            },
          ).message,
          "child",
        ),
      );
      main.start();
      return;
    }
    final main = Fiber.main(() {
      Fiber.fork(child);
      Fiber.suspend();
    });
    Expect.equals(Expect.throws<FiberException>(main.start).message, "child");
    return;
  }
  if (childYield) {
    final child = Fiber.child(() => Fiber.suspend(), name: "child");
    if (mainCatchChild) {
      final main = Fiber.main(
        () => Expect.equals(
          Expect.throws<FiberException>(() {
            Fiber.fork(child);
            throw FiberException("main");
          }).message,
          "main",
        ),
      );
      main.start();
      return;
    }
    final main = Fiber.main(() {
      Fiber.fork(child);
      throw FiberException("main");
    });
    Expect.equals(Expect.throws<FiberException>(main.start).message, "main");
    return;
  }
  if (childException) {
    final child = Fiber.child(() => throw FiberException("child"), name: "child");
    if (mainCatchChild) {
      final main = Fiber.main(() => Expect.equals(Expect.throws<FiberException>(() => Fiber.fork(child)).message, "child"));
      main.start();
      return;
    }
    final main = Fiber.main(() => Fiber.fork(child));
    Expect.equals(Expect.throws<FiberException>(main.start).message, "child");
    return;
  }
  if (mainException) {
    final main = Fiber.main(() => throw FiberException("main"));
    Expect.equals(Expect.throws<FiberException>(main.start).message, "main");
  }
}
