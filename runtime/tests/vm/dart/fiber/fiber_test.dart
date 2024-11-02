import 'dart:fiber';
import 'dart:async';
import 'package:expect/expect.dart';
import 'fiber_base_suite.dart' as base;
import 'fiber_launch_suite.dart' as launch;

final suites = {
  "launch": launch.tests,
};

void main(List<String> arguments) {
  if (arguments.isEmpty) throw ArgumentError();
  final suite = suites[arguments[0]];
  if (suite == null) return;
  print("Processing suite: ${arguments[0]}");
  for (var test in suite!) {
    if (arguments.length == 1 || test.toString().toLowerCase().contains("void from Function 'test${arguments[1]}'".toLowerCase())) {
      print("Processing test: ${test.toString()}");
      test();
      print("Test: ${test.toString()} finished");
    }
  }
  print("Suite: ${arguments[0]} finished");
}
