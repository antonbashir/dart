import 'dart:fiber';
import 'dart:async';
import 'package:expect/expect.dart';

final tests = [
  testGlobalState,
  testClosureState,
];

var globalStateValue = "";
void testGlobalState() {
  void child() {
    globalStateValue += "child -> ";
    Fiber.reschedule();
    globalStateValue += "child";
  }

  void main() {
    globalStateValue = "";
    globalStateValue += "main -> ";
    Fiber.schedule(Fiber.current);
    Fiber.spawn(child);
    globalStateValue += "main -> ";
    Fiber.reschedule();
    Expect.equals("main -> child -> main -> child", globalStateValue);
  }

  Fiber.launch(main, terminate: true);
}

void testClosureState() {
  var localState = "localState";
  Fiber.launch(
    () {
      Expect.equals("localState", localState);
      localState = "after fiber";
    },
    terminate: true,
  );
  Expect.equals("after fiber", localState);

  localState = "localState";
  Fiber.launch(
    () {
      Expect.equals("localState", localState);
      localState = "after main fiber";
      Fiber.schedule(Fiber.current);
      Fiber.spawn(
        () {
          Expect.equals("after main fiber", localState);
          localState = "after child fiber";
          Fiber.reschedule();
          Expect.equals("after child fiber after main fiber", localState);
          localState = "finish";
        },
        name: "child",
      );
      Expect.equals("after child fiber", localState);
      localState = "after child fiber after main fiber";
      Fiber.suspend();
    },
    terminate: true,
  );
  Expect.equals("finish", localState);

  localState = "level 1";
  Fiber.launch(
    () {
      Expect.equals("level 1", localState);
      localState = "level 2";
      Fiber.spawn(
        () {
          Expect.equals("level 2", localState);
          localState = "level 3";
          Fiber.spawn(
            () {
              Expect.equals("level 3", localState);
              localState = "level 4";
            },
            name: "child",
          );
        },
        name: "child",
      );
    },
    terminate: true,
  );
  Expect.equals("level 4", localState);
}
