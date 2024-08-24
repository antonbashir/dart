import "dart:_internal" show patch;
import "dart:fiber";
import "dart:ffi";

@pragma("vm:recognized", "other")
@pragma("vm:external-name", "Fiber_coroutineInitialize")
external void _coroutineInitialize(_Coroutine from, _Coroutine to, Function entry);

@pragma("vm:recognized", "other")
@pragma("vm:never-inline")
external void _coroutineResume(_Coroutine to);

@pragma("vm:recognized", "other")
@pragma("vm:external-name", "Fiber_coroutineTransfer")
external void _coroutineTransfer(_Coroutine from, _Coroutine to);

@pragma("vm:entry-point")
class _Coroutine {
  @pragma("vm:entry-point")
  static int? _current;
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
    _initialize(_coroutine, _entry);
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
  void _initialize(_Coroutine _coroutine, void Function() entry) {
    _coroutineInitialize(_constructor, _coroutine, entry);
  }
}
