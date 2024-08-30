import 'dart:fiber';
import 'dart:async';

final mainFiber = Fiber.main(size: 1024 * 1024, entry: mainEntry);
final childFiber = Fiber.child(size: 1024 * 1024, entry: childEntry, name: "child");

var commonState = "";

void main() {
  print("before start");
  mainFiber.start();
  print("after start");
}

void mainEntry() {
  print("main: entry");
  commonState += "main -> ";
  mainFiber.fork(childFiber);
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
