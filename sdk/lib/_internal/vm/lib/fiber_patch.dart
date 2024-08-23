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
  void start() {
    if (_state == FiberState.running) return;
    _construct(_coroutine, _entry);
    _coroutineResume(_coroutine);
  }
  
  @patch
  void fork(Fiber child) {
    if (_state != FiberState.running) return;
    if (child._state == FiberState.running) return;
    child._construct(child._coroutine, child._entry);
    _coroutineTransfer(_coroutine, child._coroutine);
  }

  @patch
  void transfer(Fiber to) {
    _coroutineTransfer(_coroutine, to._coroutine);
  }

  void _construct(_Coroutine _coroutine, void Function() entry) {
    print("_construct:_coroutineSuspend");
    _coroutineSuspend(_constructor);
    print("_construct:_coroutineSuspend after");
    if (_state == FiberState.launched) {
      print("_construct return");
      return;
    }
    _create(_constructor, _coroutine, entry);
  }

  void _create(_Coroutine from, _Coroutine to, void Function() entry) {
    print("_create:_coroutineSuspend");
    _coroutineSuspend(to);
    print("_create:_coroutineSuspend after");
    if (_state == FiberState.launched) {
      _state = FiberState.running;
      entry();
      _state = FiberState.finished;
      return;
    }
    _state = FiberState.launched;
    print("_create:_coroutineResume");
    _coroutineResume(from);
    print("_create:_coroutineResume after");
  }
}
