import "dart:_internal" show patch;
import "dart:fiber";
import "dart:ffi";

@pragma("vm:recognized", "other")
@pragma("vm:external-name", "Fiber_coroutineSuspend")
external void _coroutineSuspend(dynamic to);

@pragma("vm:recognized", "other")
@pragma("vm:external-name", "Fiber_coroutineTransfer")
external void _coroutineTransfer(dynamic from, dynamic to);

@pragma("vm:recognized", "other")
@pragma("vm:never-inline")
external void _coroutineResume(dynamic to);

@pragma("vm:entry-point")
class _Coroutine {
  @pragma("vm:external-name", "Coroutine_factory")
  external factory _Coroutine._(Pointer<Void> stack, dynamic entry);
}

@patch
class Fiber {
  final _Coroutine _coroutine;
  final void Function() _entry;
  final _Coroutine _defaultCoroutine = _Coroutine._(nullptr, null);
  var _launched = false;

  @patch
  Fiber({required FiberStack stack, required void Function() entry}) : _entry = entry, _coroutine = _Coroutine._(stack.pointer, entry);

  void _coroutineCreate(dynamic from, dynamic to, dynamic entry) {
    _coroutineSuspend(to);
    if (_launched) {
      entry();
      return;
    }
    _launched = true;
    _coroutineResume(from);
  }

  @patch 
  void _suspend() {
    _coroutineSuspend(_coroutine);
  }

  @patch 
  void _resume() {
    _coroutineResume(_coroutine);
  }

  @patch 
  void _transfer(Fiber to) {
    _coroutineTransfer(_coroutine, to._coroutine);
  }

  @patch
  void _run() {
    _coroutineSuspend(_defaultCoroutine);
    if (_launched) {
      return;
    }
    _coroutineCreate(_defaultCoroutine, _coroutine, _entry);
  }
}
