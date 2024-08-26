import "dart:_internal" show patch;
import "dart:fiber";
import "dart:async";
import "dart:ffi";

const _kRootContextSize = 4096;

@pragma("vm:recognized", "other")
@pragma("vm:external-name", "Fiber_coroutineInitialize")
external void _coroutineInitialize(_Coroutine from, _Coroutine to);

@pragma("vm:recognized", "other")
@pragma("vm:external-name", "Fiber_coroutineTransfer")
external void _coroutineTransfer(_Coroutine from, _Coroutine to);

@pragma("vm:entry-point")
class _Coroutine {
  @pragma("vm:external-name", "Coroutine_factory")
  external factory _Coroutine._(int size);
}

@patch
class Fiber {
  final _root = _Coroutine._(_kRootContextSize, null);
  final void Function() _entry;
  _Coroutine _current;
  
  @patch
  FiberState get state => _state;
  var _state = FiberState.created;

  @patch
  @pragma("vm:never-inline")
  Fiber({required int size, required void Function() entry, required String name}): this.name = name, _entry = entry, _current = _Coroutine._(size) {
    _coroutineInitialize(_root, _current);
    if (_state == FiberState.created) {
      _state = FiberState.initialized;
      _launch();
    }
  }

  @pragma("vm:never-inline")
  void _launch() {
    _coroutineTransfer(_current, _root);
    _entry();
    _coroutineTransfer(_current, _root);
  }
  
  @patch
  @pragma("vm:prefer-inline")
  void start() {
    if (_state == FiberState.initialized) {
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
