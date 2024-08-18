import "dart:_internal" show patch;
import "dart:fiber";

@pragma("vm:external-name", "Fiber_suspend")
external void _fiberSuspend();

@pragma("vm:recognized", "other")
@pragma("vm:never-inline")
external Object? _coroutineTransfer(Object? nothing);

@patch
class Fiber {
  @patch
  @pragma("vm:prefer-inline")
  static void suspend() {
    print(_coroutineTransfer("test"));
  }
}
