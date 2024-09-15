import 'dart:fiber';
import 'dart:async';
import 'package:expect/expect.dart';

final mainFiber = Fiber.main(mainEntry, managed: true);

var commonState = "";

void main() {
  testBase();
  testClosureScopes();
  testRecycle();
}

void testBase() {
  mainFiber.start();
  commonState = "";
}

void testRecycle() {
  mainFiber.start();
  commonState = "";
  mainFiber.start();
}

void testClosureScopes() {
  var variable = "variable";
  Fiber.launch(
    () {
      Expect.equals("variable", variable);
      variable = "after fiber";
    },
  );
  Expect.equals("after fiber", variable);
  variable = "variable";
  Fiber.launch(
    () {
      Expect.equals("variable", variable);
      variable = "after main fiber";
      Fiber.spawn(
        () {
          Expect.equals("after main fiber", variable);
          variable = "after child fiber";
          Fiber.suspend();
          Expect.equals("after child fiber after main fiber", variable);
          variable = "finish";
        },
        name: "child",
      );
      Expect.equals("after child fiber", variable);
      variable = "after child fiber after main fiber";
      Fiber.suspend();
    },
  );
  Expect.equals("finish", variable);

  variable = "level 1";
  Fiber.launch(
    () {
      Expect.equals("level 1", variable);
      variable = "level 2";
      Fiber.spawn(
        () {
          Expect.equals("level 2", variable);
          variable = "level 3";
          Fiber.spawn(
            () {
              Expect.equals("level 3", variable);
              variable = "level 4";
            },
            name: "child",
          );
        },
        name: "child",
      );
    },
  );

  Expect.equals("level 4", variable);
}

void mainEntry() {
  commonState += "main -> ";
  Fiber.spawn(childEntry);
  commonState += "main -> ";
  Fiber.suspend();
  Expect.equals("main -> child -> main -> child", commonState);
}

void childEntry() {
  commonState += "child -> ";
  Fiber.suspend();
  commonState += "child";
}
