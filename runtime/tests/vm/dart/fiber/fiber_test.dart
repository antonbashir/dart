import 'dart:fiber';
import 'dart:async';
import 'package:expect/expect.dart';
import 'fiber_lifecycle_suite.dart' as lifecycle;
import 'fiber_launch_suite.dart' as launch;
import 'fiber_state_suite.dart' as state;

final suites = {
  "launch": launch.tests,
  "state": state.tests,
  "lifecycle": lifecycle.tests,
};

void main(List<String> arguments) {
  if (arguments.isEmpty) {
    for (var suite in suites.entries) {
      print("Processing suite: ${suite.key}");
      for (var test in suite.value) {
        final function = RegExp(r"Function 'test(.+)'").firstMatch(test.toString())!.group(1);
        print("Processing test: test${function}");
        test();
        print("Test: test${function} finished");
      }
      print("Suite: ${suite.key} finished\n");
    }
    return;
  }
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
