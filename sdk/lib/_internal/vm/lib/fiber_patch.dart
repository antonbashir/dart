import "dart:_internal" show patch;
import "dart:fiber";
import "dart:ffi";

@pragma("vm:recognized", "other")
@pragma("vm:never-inline")
external void _coroutineTransfer(dynamic from, dynamic to);

@pragma("vm:recognized", "other")
@pragma("vm:never-inline")
external void _coroutineInitialize(dynamic from, dynamic to);

@pragma("vm:entry-point")
@pragma("vm:never-inline")
void _coroutineCreate(dynamic from, dynamic to, dynamic entry) {
  print("_coroutineInitialize");
  if (to is _Coroutine && entry is Function) {
    print("_coroutineInitialize -> _coroutineTransfer 1");
    _coroutineTransfer(to, from);
    print("_coroutineInitialize -> _coroutineTransfer 2");
    print("_coroutineInitialize -> entry 1");
    entry();
    print("_coroutineInitialize -> entry 2");
  }
}

@pragma("vm:entry-point")
class _Coroutine {
  @pragma("vm:external-name", "Coroutine_factory")
  external factory _Coroutine._(
    Pointer<Void> stack,
    dynamic entry,
  );
}

@patch
class Fiber {
  final _Coroutine _coroutine;
  static late final _Coroutine _defaultCoroutine = _Coroutine._(nullptr, null);

  @patch
  Fiber({required FiberStack stack, required void Function() entry})
      : _coroutine = _Coroutine._(
          stack.pointer,
          entry,
        );

  @patch
  void _run() {
    print("before _coroutineTransfer");
    _coroutineInitialize(_defaultCoroutine, _coroutine);
    print("after _coroutineTransfer");
    _coroutineTransfer(_defaultCoroutine, _coroutine);
  }
}
