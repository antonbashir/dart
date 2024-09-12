import 'dart:fiber';
import 'dart:async';
import 'package:expect/expect.dart';

final mainFiber = Fiber.main(mainEntry);

var commonState = "";

void main() {
  testBase();
  testClosureScopes();
  testTransfer();
  testReturnToFinished();
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

void testTransfer() {
  Fiber.launch(() {
    var state = "main";
    var switches = 0;
    final first = Fiber.child(
      () {
        switches++;
        Expect.equals("created", state);
        state = "first";
      },
      run: false,
    );
    Fiber.fork(first);

    final second = Fiber.child(
      () {
        switches++;
        Expect.equals("first", state);
        state = "second";
      },
      run: false,
    );
    Fiber.fork(second);

    state = "created";
    Fiber.transfer(first);
    switches++;
    Expect.equals("first", state);

    Fiber.transfer(second);
    switches++;
    Expect.equals("second", state);

    Expect.equals(4, switches);
  });
}

void testReturnToFinished() {
  late Fiber second;
  late Fiber main;
  late Fiber first;
  var state = "";
  main = Fiber.main(() {
    state = "main";
    first = Fiber.child(
      () {
        state += " -> first";
        second = Fiber.child(
          () {
            state += " -> second";
            Fiber.transfer(main);
            state += " -> second";
          },
        );
        Fiber.fork(second);
        state += " -> first";
      },
    );

    Fiber.fork(first);

    state += " -> main";

    Fiber.transfer(first);

    state += " -> main";

    Fiber.transfer(second);
  });
  main.start();
  state += " -> exit";
  Expect.equals("main -> first -> second -> main -> first -> main -> second -> exit", state);
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
