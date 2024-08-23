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

void main() {
  print("before run");
  mainFiber.run();
  print("after run");
  mainFiber.resume();
}

void mainEntry() {
  print("entry");
  childFiber.run();
  print("main transfer");
  mainFiber.transfer(childFiber);
  print("child transfer finished");
}

void childEntry() {
  print("child entry");
  childFiber.transfer(mainFiber);
  print("child transfer");
}