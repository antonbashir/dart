import 'dart:fiber';
import 'dart:async';
import 'package:expect/expect.dart';

final mainFiber = Fiber.main(entry: mainEntry);
final childFiber = Fiber.child(entry: childEntry, name: "child");

var commonState = "";

void main() {
  mainFiber.start();
  var variable = "variable";
  Fiber.main(
    entry: () {
      Expect.equals("variable", variable);
      variable = "after fiber";
    },
  ).start();
  Expect.equals("after fiber", variable);
  variable = "variable";
  Fiber.main(
    entry: () {
      Expect.equals("variable", variable);
      variable = "after main fiber";
      Fiber.spawn(
        Fiber.child(
          entry: () {
            Expect.equals("after main fiber", variable);
            variable = "after child fiber";
            Fiber.suspend();
            Expect.equals("after child fiber after main fiber", variable);
            variable = "finish";
          },
          name: "child",
        ),
      );
      Expect.equals("after child fiber", variable);
      variable = "after child fiber after main fiber";
      Fiber.suspend();
    },
  ).start();
  Expect.equals("finish", variable);

  variable = "level 1";
  Fiber.main(
    entry: () {
      Expect.equals("level 1", variable);
      variable = "level 2";
      Fiber.spawn(
        Fiber.child(
          entry: () {
            Expect.equals("level 2", variable);
            variable = "level 3";
            Fiber.spawn(
              Fiber.child(
                name: "child",
                entry: () {
                  Expect.equals("level 3", variable);
                  variable = "level 4";
                },
              ),
            );
          },
          name: "child",
        ),
      );
    },
  ).start();
  Expect.equals("level 4", variable);
}

void mainEntry() {
  commonState += "main -> ";
  Fiber.spawn(childFiber);
  commonState += "main -> ";
  Fiber.suspend();
  Expect.equals("main -> child -> main -> child", commonState);
}

void childEntry() {
  commonState += "child -> ";
  Fiber.suspend();
  commonState += "child";
}
