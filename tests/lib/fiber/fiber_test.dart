import 'dart:fiber';

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
  notinlfunc();
  print(commonState);
}

@pragma("vm:never-inline")
void notinlfunc() {
  mainFiber.transfer(childFiber);
}

@pragma("vm:prefer-inline")
void inlfunc() {
  mainFiber.transfer(childFiber);
}

void childEntry() {
  print("child: entry");
  commonState += "child -> ";
  childFiber.transfer(mainFiber);
  print("child: after main transfer");
  commonState += "child";
}
