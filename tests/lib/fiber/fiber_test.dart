import 'dart:developer';
import 'dart:fiber';
import 'package:expect/expect.dart';

Future<void> main() async {
  Fiber.suspend();
}