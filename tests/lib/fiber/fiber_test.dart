import 'dart:fiber';
import 'dart:async';

final mainFiber = Fiber.main(entry: mainEntry);
final childFiber = Fiber.child(entry: childEntry, name: "child");

var commonState = "";

void main() {
  while (true) {
    print("before idle");
    Fiber.idle();
    print("after idle");
    commonState = "";
    print("before start");
    mainFiber.start();
    print("after start");
  }
}

void mainEntry() {
  print("main: entry");
  commonState += "main -> ";
  mainFiber.fork(childFiber);
  print("main: after child fork");
  commonState += "main -> ";
  print("main: after child transfer");
  mainFiber.transfer(childFiber);
  print(commonState);
}

void childEntry() {
  print("child: entry");
  commonState += "child -> ";
  childFiber.transfer(mainFiber);
  print("child: after main transfer");
  commonState += "child";
}
