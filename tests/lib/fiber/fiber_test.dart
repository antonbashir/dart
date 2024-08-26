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
String f1() {
  return "f1";
}

@pragma("vm:prefer-inline")
String f2(String r) {
  return "f2$r";
}

@pragma("vm:prefer-inline")
double f3(double r) {
  return r * r * r * r;
}

@pragma("vm:never-inline")
void mainEntry() {
  print("main: entry");
  var r1 = f1();
  print(f2(r1));
  var r2 = f1();
  print(f2(r2));
  var r3 = f1();
  print(f2(r3));
  var r4 = f1();
  print(f2(r4));
  var r5 = f1();
  double res = f3(3563.0243423);
  mainFiber.transfer(childFiber);
  r5 = "$r2 $r1 $r3 $r4 ${res + 1234}";
  print(f2(r1));
  print(f3(res));
  print(f2(r2));
  print(f2(r3));
  print(f2(r4));
  print(f2(r5));
  r1 = f1();
  r2 = f1();
  r3 = f1();
  r4 = f1();
  r5 = f1();
}

@pragma("vm:never-inline")
void childEntry() {
  print("child: entry");
  childFiber.transfer(mainFiber);
}