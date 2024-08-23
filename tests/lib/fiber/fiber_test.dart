import 'dart:ffi';
import 'package:ffi/ffi.dart';
import 'dart:fiber';

final fiber = Fiber(
  stack: FiberStack((pointer: calloc<Uint8>(1024 * 1024).cast(), size: 1024 * 1024)),
  entry: entry,
);

void main() {
  print("before run");
  fiber.run();
  print("after run");
}

void entry() {
  print("entry");
}