import 'dart:fiber';
import 'dart:async';
import 'package:expect/expect.dart';

final tests = [
  testDisposed,
];

void testDisposed() {
  Fiber.launch(
    () {
      final child = Fiber.child(() => {}, persistent: false);
      Fiber.fork(child);
      Expect.isTrue(child.state.disposed);
    },
  );
}
