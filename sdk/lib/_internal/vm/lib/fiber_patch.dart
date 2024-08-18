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
    print(new _Coroutine(1234));
  }
}

@pragma("vm:entry-point")
class _Coroutine implements Coroutine {
  factory _Coroutine(int stackSize) {
    return _Coroutine._(stackSize);
  }

  @pragma("vm:external-name", "Coroutine_factory")
  external factory _Coroutine._(int stackSize);

}