import 'dart:ffi';
import 'package:ffi/ffi.dart';
import 'dart:fiber';

final mainFiber = Fiber(
  stack: FiberStack((pointer: calloc<Uint8>(1024 * 1024).cast(), size: 1024 * 1024)),
  entry: mainEntry,
);
final childFiber = Fiber(
  stack: FiberStack((pointer: calloc<Uint8>(1024 * 1024).cast(), size: 1024 * 1024)),
  entry: childEntry,
);

var _transferred = false;

var target = 0;

void main() {
  print("before start");
  mainFiber.start();
  print("after start");
  mainFiber.launch();
  print("after launch");
}

@pragma("vm:never-inline")
void mainEntry() {
  print("entry");  
  childFiber.start();
  print("fork");
  var target = 3;
  mainFiber.transfer(childFiber);
  target += 3;
  print(target);
  print("main");
  mainFiber.transfer(childFiber);
} 

@pragma("vm:never-inline")
void childEntry() {
  print("child entry");
  childFiber.transfer(mainFiber);
  print("child");
}