import 'dart:fiber';
import 'dart:async';
import 'package:expect/expect.dart';

final tests = [
  testReturnParent,
  testReturnParentSuspend,
  testReturnParentDead,
];

void testReturnParent() {
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
  );
}

void testReturnParentSuspend() {
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
  );
}

void testReturnParentDead() {
  Fiber.launch(
    () {
      var state = "main";

      final child1 = Fiber.child(() {
        Expect.equals("child2", state);
        state = "child1";
        Fiber.reschedule();
        Expect.equals("child2.dead", state);
        state = "child1.dead";
      });

      final child2 = Fiber.child(() {
        state = "child2";
        Fiber.fork(child1);
        Expect.equals("child1", state);
        state = "child2.dead";
      });

      Fiber.fork(child2);

      Fiber.reschedule();

      Expect.equals("child1.dead", state);
    },
  );
}
