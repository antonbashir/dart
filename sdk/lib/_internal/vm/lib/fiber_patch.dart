import "dart:_internal" show patch;
import "dart:fiber";

@pragma("vm:external-name", "Fiber_suspend")
external void _fiberSuspend();

@pragma("vm:recognized", "other")
@pragma("vm:never-inline")
external void _coroutineTransfer();

@patch
class Fiber {
  @patch
  static void suspend() {
    _coroutineTransfer();
  }
}
