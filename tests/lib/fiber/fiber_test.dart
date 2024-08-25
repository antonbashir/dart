import 'dart:ffi';
import 'dart:fiber';

final mainFiber = Fiber(size: 1024 * 1024, entry: mainEntry, name: "main");
final childFiber = Fiber(size: 1024 * 1024, entry: childEntry, name: "child");

void main() {
  mainFiber.construct();
  print("before start");
  mainFiber.start();
  print("after start");
}

@pragma("vm:never-inline")
void mainEntry() {
  print("main: entry");  
  childFiber.construct();
  print("main: transfer");
  var s = str("abc,");
  print(s);
  print("main: after first transfer");
}

@pragma("vm:prefer-inline")
String str(String v) {
  mainFiber.transfer(childFiber);
  return v + "-test";
}

@pragma("vm:never-inline")
void childEntry() {
  print("child: entry");
  childFiber.transfer(mainFiber);
  print("child: after transfer");
}