import "dart:_internal" show patch;
import "dart:fiber";
import "dart:ffi";

@pragma("vm:recognized", "other")
@pragma("vm:never-inline")
external void _coroutineTransfer(dynamic from, dynamic to);

@pragma("vm:entry-point")
class _Coroutine {
  @pragma("vm:external-name", "Coroutine_factory")
  external factory _Coroutine._(Pointer<Void> stack, int size, dynamic entry);
}

@patch
class Fiber {
  final _Coroutine _coroutine;
  static late final _Coroutine _defaultCoroutine = _Coroutine._(nullptr, 0, null);

  @patch
  Fiber({required FiberStack stack, required void Function() entry}) : _coroutine = _Coroutine._(stack.pointer, stack.size, entry);

  @patch
  void _run() {
    _coroutineTransfer(_defaultCoroutine, _coroutine);
  }
}
