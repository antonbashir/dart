import "dart:_internal" show patch;
import "dart:fiber";
import "dart:async";
import "dart:ffi";

const _kRootContextSize = 4096;

@pragma("vm:recognized", "other")
@pragma("vm:external-name", "Fiber_coroutineInitialize")
external void _coroutineInitialize(_Coroutine from, _Coroutine to, Function entry);

@pragma("vm:recognized", "other")
@pragma("vm:external-name", "Fiber_coroutineTransfer")
external void _coroutineTransfer(_Coroutine from, _Coroutine to);

@pragma("vm:entry-point")
void _coroutineLaunch(_Coroutine from, _Coroutine to, void Function() entry) {
  print("_coroutineLaunch");
  _coroutineTransfer(to, from);
  entry();
}

@pragma("vm:entry-point")
class _Coroutine {
  @pragma("vm:external-name", "Coroutine_factory")
  external factory _Coroutine._(int size);
}

@patch
class Fiber {
  final _Coroutine _current;
  final _Coroutine _root = _Coroutine._(_kRootContextSize);
  final void Function() _entry;
  
  @patch
  FiberState get state => _state;
  var _state = FiberState.created;

  @patch
  Fiber({required int size, required void Function() entry}): _entry = entry, _current = _Coroutine._(size) {
    print("fiber.constructor");
    _coroutineInitialize(_root, _current, entry);
    print("after _coroutineInitialize");
    _state = FiberState.initialized;
  }

  @patch
  @pragma("vm:prefer-inline")
  void start() {
    if (state == FiberState.initialized) {
      _state = FiberState.running;
      _coroutineTransfer(_root, _current);
      _state = FiberState.finished;
    }
  }

  @patch
  @pragma("vm:prefer-inline")
  void transfer(Fiber to) {
    _coroutineTransfer(_current, to._current);
  }

}
