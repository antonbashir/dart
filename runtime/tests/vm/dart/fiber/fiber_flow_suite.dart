import 'dart:fiber';
import 'dart:async';
import 'package:expect/expect.dart';

final tests = [
  testReturnToParent,
  testReturnToParentAfterSuspend,
];

void testReturnToParent() {
  Fiber.launch(
    () {
      Fiber.child(() {
        var state = "child1";
        Fiber.spawn(() {
          Expect.equals(state, "child1");
          state = "child2";
        });
        Expect.equals(state, "child2");
      });
    },
    terminate: true,
  );
}

void testReturnToParentAfterSuspend() {
  Fiber.launch(
    () {
      Fiber.child(() {
        var state = "child1";
        Fiber.spawn(() {
          Expect.equals(state, "child1");
          state = "child2";
          Fiber.reschedule();
          state = "child2.suspended";
        });
        Expect.equals(state, "child2");
        Fiber.suspend();
        Expect.equals(state, "child2.suspended");
      });
    },
    terminate: true,
  );
}
