import 'dart:fiber';
import 'dart:async';
import 'package:expect/expect.dart';

void main() {
  _run(mainException: true);
  _run(childException: true);
  _run(childException: true, mainCatchChild: true);
}

class FiberException implements Exception {
  final String message;
  const FiberException(this.message);
}

void _run({mainException = false, childException = false, mainCatchChild = false}) {
  print("_run: mainException = $mainException, childException = $childException, mainCatchChild = $mainCatchChild");
  if (childException) {
    final child = Fiber.child(entry: () => throw FiberException("child"), name: "child");
    if (mainCatchChild) {
      final main = Fiber.main(entry: () => Expect.equals(Expect.throws<FiberException>(() => Fiber.spawn(child)).message, "child"));
      main.start();
      return;
    }
    final main = Fiber.main(entry: () => Fiber.spawn(child));
    Expect.equals(Expect.throws<FiberException>(main.start).message, "child");
  }
  if (mainException) {
    final main = Fiber.main(entry: () => throw FiberException("main"));
    Expect.equals(Expect.throws<FiberException>(main.start).message, "main");
  }
}
