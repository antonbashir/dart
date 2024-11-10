import 'dart:fiber';
import 'dart:async';
import 'package:expect/expect.dart';

final tests = [
  testRecycle,
  testDisposed,
];

void testRecycle() {
  Fiber.launch(
    () {
      var localState = "main";
      final child = Fiber.child(() => localState = "$localState -> child", persistent: true);
      Fiber.fork(child);
      Expect.isTrue(child.state.finished);
      Fiber.fork(child);
      Expect.isTrue(child.state.finished);
      Expect.equals("main -> child -> child", localState);
    },
    terminate: true,
  );
}

void testDisposed() {
  Fiber.launch(
    () {
      final child = Fiber.child(() => {}, persistent: false);
      Fiber.fork(child);
      Expect.isTrue(child.state.disposed);
    },
    terminate: true,
  );
}
