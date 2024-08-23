import 'dart:ffi';
import 'package:ffi/ffi.dart';
import 'dart:fiber';

final firstFiber = Fiber(
  stack: FiberStack((pointer: calloc<Uint8>(1024 * 1024).cast(), size: 1024 * 1024)),
  entry: firstEntry,
);

final secondFiber = Fiber(
  stack: FiberStack((pointer: calloc<Uint8>(1024 * 1024).cast(), size: 1024 * 1024)),
  entry: secondEntry,
);

var _firstLaunched = false;
var _secondLaunched = false;

void main() {
  firstFiber.run();
}

void firstEntry() {
  print("hello, first entry");
  first();
}

void secondEntry() {
  print("hello, second entry");
  second();
}

void first() {
  print("hello, first fiber");
  firstFiber.suspend();
  print(sw.elapsedMicroseconds);
  if (_firstLaunched) {
    print("hello, first resumed fiber");
    secondFiber.resume();
    return;
  }
  _firstLaunched = true;
  print("hello, first suspended fiber");
  secondFiber.run();
}

void second() {
  print("hello, second fiber");
  secondFiber.suspend();
  if (_secondLaunched) {
    print("hello, second resumed fiber");
    return;
  }
  _secondLaunched = true;
  print("hello, second suspended fiber");
  sw.start();
  firstFiber.resume();
}