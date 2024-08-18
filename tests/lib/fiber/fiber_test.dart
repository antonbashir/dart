import 'dart:developer';
import 'dart:fiber';
import 'dart:ffi';
import 'package:expect/expect.dart';

void main() {
  Fiber(
   stack: FiberStack((pointer: nullptr, size: 0)), 
   entry: entry,
  );
}

void entry() {
  print("hello, coro");
}