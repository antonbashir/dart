import 'dart:ffi';
import 'dart:fiber';

final mainFiber = Fiber(size: 1024 * 1024, entry: mainEntry, name: "main");
final childFiber = Fiber(size: 1024 * 1024, entry: childEntry, name: "child");

void main() {
  print("before start");
  mainFiber.start();
  print("after start");
}

@pragma("vm:never-inline")
void mainEntry() {
  print("main: entry");
  mainFiber.fork(childFiber);
  print("main: after first transfer");
  mainFiber.transfer(childFiber);
}

@pragma("vm:never-inline")
void childEntry() {
  print("child: entry");
  childFiber.transfer(mainFiber);
}