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
  final _Coroutine _current;
  final _Coroutine _root = _Coroutine._(_kRootContextSize);
  final void Function() _entry;
  
  @patch
  FiberState get state => _state;
  var _state = FiberState.created;

  @patch
  Fiber({required int size, required void Function() entry}): _entry = entry, _current = _Coroutine._(size) {
    _coroutineInitialize(_root, _current);
  }

  @patch
  @pragma("vm:prefer-inline")
  void launch() {
    _coroutineTransfer(_root, _coroutine);
  }

  @patch
  @pragma("vm:prefer-inline")
  void transfer(Fiber to) {
    _coroutineTransfer(_coroutine, to._coroutine);
  }

  @pragma("vm:entry-point")
  @pragma("vm:never-inline")
  void _initialize() {
    _state = Fiber.initialized;
    _coroutineTransfer(_current, _root);
    _state = Fiber.running;
    _entry();
    _state = Fiber.finished;
  }
}
