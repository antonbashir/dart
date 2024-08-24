import "dart:_internal" show patch;
import "dart:fiber";
import "dart:ffi";

@pragma("vm:recognized", "other")
@pragma("vm:external-name", "Fiber_coroutineSuspend")
external void _coroutineSuspend(_Coroutine to);

@pragma("vm:recognized", "other")
@pragma("vm:never-inline")
external void _coroutineResume(_Coroutine to);

@pragma("vm:recognized", "other")
@pragma("vm:external-name", "Fiber_coroutineTransfer")
external void _coroutineTransfer(_Coroutine from, _Coroutine to);

@pragma("vm:entry-point")
class _Coroutine {
  @pragma("vm:entry-point")
  static int? _stack;
  @pragma("vm:external-name", "Coroutine_factory")
  external factory _Coroutine._(Pointer<Void> stack);
}

@patch
class Fiber {
  final _Coroutine _coroutine;
  final void Function() _entry;
  final _Coroutine _constructor = _Coroutine._(nullptr);
  
  var _state = FiberState.created;
  
  @patch
  FiberState get state => _state;

  @patch
  Fiber({required FiberStack stack, required void Function() entry}): 
    _entry = entry,
    _coroutine = _Coroutine._(stack.pointer);

  @patch
  @pragma("vm:prefer-inline")
  void start() {
    if (_state == FiberState.running) return;
    _construct(_coroutine, _entry);
  }

  @patch
  @pragma("vm:prefer-inline")
  void launch() {
    _coroutineResume(_coroutine);
  }

  @patch
  @pragma("vm:prefer-inline")
  void transfer(Fiber to) {
    _coroutineTransfer(_coroutine, to._coroutine);
  }

  @pragma("vm:never-inline")
  void _construct(_Coroutine _coroutine, void Function() entry) {
    _coroutineSuspend(_constructor);
    if (_state == FiberState.launched) {
      return;
    }
    _create(_constructor, _coroutine, entry);
  }

  @pragma("vm:never-inline")
  void _create(_Coroutine from, _Coroutine to, void Function() entry) {
    _coroutineSuspend(to);
    if (_state == FiberState.launched) {
      _state = FiberState.running;
      entry();
      _state = FiberState.finished;
      return;
    }
    _state = FiberState.launched;
    _coroutineResume(from);
  }
}
