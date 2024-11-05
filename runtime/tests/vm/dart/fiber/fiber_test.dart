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
    final function = RegExp(r"Function 'test(.+)'").firstMatch(test.toString())!.group(1);
    if (arguments.length == 1 || function == arguments[1].toLowerCase()) {
      print("Processing test: test${function}");
      test();
      print("Test: test${function} finished");
    }
  }
  print("Suite: ${arguments[0]} finished");
}
