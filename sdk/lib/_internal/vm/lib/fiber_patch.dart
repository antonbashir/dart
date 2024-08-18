import "dart:_internal" show patch;
import "dart:fiber";

@pragma("vm:external-name", "Fiber_suspend")
external _fiberSuspend();

@patch
class Fiber {
  @patch
  static void suspend() {
    _fiberSuspend();
  }
}
