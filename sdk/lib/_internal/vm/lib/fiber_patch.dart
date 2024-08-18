import "dart:_internal" show patch;
import "dart:fiber";

@pragma("vm:recognized", "other")
@pragma("vm:never-inline")
external Object? _coroutineTransfer(Object? nothing);

@pragma("vm:entry-point")
class _Coroutine {
  @pragma("vm:external-name", "Coroutine_factory")
  external factory _Coroutine._(int stackSize);
}

@patch
class Fiber {
  final _Coroutine _coroutine;

  @patch
  Fiber({required int stackSize}) : _coroutine = _Coroutine._(stackSize);
}
