import 'dart:fiber';
import 'dart:async';

var commonState = "";

class FiberEntry {
  final String v;
  FiberEntry(this.v);

  void call() {
    print("entry: $v");
  }
}

void main() {
  commonState = "common";
  final entry = FiberEntry("test");
  Fiber.main(entry: () {
    print(commonState);
    commonState = "common 2";
  }).start();
  print(commonState);
}
