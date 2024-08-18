import "dart:_internal" show patch;
import "dart:fiber";
import "dart:ffi";

@pragma("vm:recognized", "other")
@pragma("vm:never-inline")
external Object? _coroutineTransfer(Object? nothing);

@pragma("vm:entry-point")
class _Coroutine {
  @pragma("vm:external-name", "Coroutine_factory")
  external factory _Coroutine._(Pointer<Void> stack, int size, void Function() entry);
}

@patch
class Fiber {
  final _Coroutine _coroutine;

  @patch
  Fiber({required FiberStack stack, required void Function() entry, }) : _coroutine = _Coroutine._(stack.stack, stack.size, entry);
}
