import 'dart:developer';
import 'dart:fiber';
import 'package:expect/expect.dart';

Future<void> main() async {
  for (var i = 0; i < 1000000; i++) Fiber.suspend();
}
