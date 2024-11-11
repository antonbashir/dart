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
  Expect.equals(0, Fiber.registry.length);
  Fiber.launch(() {
    for (var i = 0; i < 32; i++) {
      Fiber.spawn(Fiber.reschedule);
    }
    Expect.equals(2 + 32, Fiber.registry.length);
  });
  Expect.equals(0, Fiber.registry.length);

  late var currentHash;
  Fiber.launch(() {
    for (var i = 0; i < 65; i++) {
      Fiber.spawn(Fiber.reschedule);
    }
    currentHash = Fiber.registry.hashCode;
    for (var i = 0; i < 65; i++) {
      Fiber.reschedule();
    }
    Expect.notEquals(currentHash, Fiber.registry.hashCode);
  });
}

void testStateLink() {}

void testProcessor() {}

void testInvariant() {}
