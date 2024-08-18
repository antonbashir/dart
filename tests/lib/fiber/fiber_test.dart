import 'dart:developer';
import 'dart:fiber';
import 'dart:ffi';
import 'package:ffi/ffi.dart';
import 'package:expect/expect.dart';

void main() {
  final fiber = Fiber(
    stack: FiberStack((pointer: calloc<Uint8>(1024 * 1024).cast(), size: 1024 * 1024)),
    entry: entry,
  );
  fiber.run();
}

void entry() {
  print("hello, coro");
}
