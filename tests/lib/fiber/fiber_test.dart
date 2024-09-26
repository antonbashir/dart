import 'dart:fiber';
import 'dart:async';
import 'package:expect/expect.dart';

var globalState = "";

void main() {
//  testBase();

  while (true) {
    print("run");
    testClosures();
    print("run end");
  }
//  testRecycle();
}

void testBase() {
  Fiber.launch(mainEntry, terminate: true);
}

void testRecycle() {
  Fiber.launch(
    () {
      var localState = "main";
      final child = Fiber.child(
        () => localState = "$localState -> child",
        persistent: true,
      );
      Fiber.fork(child);
      Fiber.fork(child);
      Expect.equals("main -> child -> child", localState);
    },
    terminate: true,
  );
}

void mainEntry() {
  globalState = "";
  globalState += "main -> ";
  Fiber.schedule(Fiber.current());
  Fiber.spawn(childEntry);
  globalState += "main -> ";
  Fiber.reschedule();
  Expect.equals("main -> child -> main -> child", globalState);
}

void childEntry() {
  globalState += "child -> ";
  Fiber.reschedule();
  globalState += "child";
}

void testClosures() {
  var localState = "localState";
  Fiber.launch(
    () {
      Expect.equals("localState", localState);
      localState = "after fiber";
    },
    terminate: true,
  );
  Expect.equals("after fiber", localState);

  // localState = "localState";
  // Fiber.launch(
  //   () {
  //     Expect.equals("localState", localState);
  //     localState = "after main fiber";
  //     Fiber.schedule(Fiber.current());
  //     Fiber.spawn(
  //       () {
  //         Expect.equals("after main fiber", localState);
  //         localState = "after child fiber";
  //         Fiber.reschedule();
  //         Expect.equals("after child fiber after main fiber", localState);
  //         localState = "finish";
  //       },
  //       name: "child",
  //     );
  //     Expect.equals("after child fiber", localState);
  //     localState = "after child fiber after main fiber";
  //     Fiber.suspend();
  //   },
  //   terminate: true,
  // );
  // Expect.equals("finish", localState);

  // localState = "level 1";
  // Fiber.launch(
  //   () {
  //     Expect.equals("level 1", localState);
  //     localState = "level 2";
  //     Fiber.spawn(
  //       () {
  //         Expect.equals("level 2", localState);
  //         localState = "level 3";
  //         Fiber.spawn(
  //           () {
  //             Expect.equals("level 3", localState);
  //             localState = "level 4";
  //           },
  //           name: "child",
  //         );
  //       },
  //       name: "child",
  //     );
  //   },
  //   terminate: true,
  // );
  // Expect.equals("level 4", localState);
}
