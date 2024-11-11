import 'dart:fiber';
import 'package:expect/expect.dart';

final tests = [
  testRegistry,
  testStateLink,
  testProcessor,
  testInvariant,
];

void testRegistry() {
  Fiber.launch(() => Expect.equals(2, Fiber.registry.length));
}

void testStateLink() {}

void testProcessor() {}

void testInvariant() {}
