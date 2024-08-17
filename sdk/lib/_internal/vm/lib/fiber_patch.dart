import "dart:_internal" show patch;
import "dart:fiber";

@pragma("vm:external-name", "DartFiber_suspend")
external _suspend();

@patch
class Fiber {
  @patch
  static void suspend() {
    _suspend();
  }
}
