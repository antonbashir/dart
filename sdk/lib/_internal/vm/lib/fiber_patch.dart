import "dart:_internal" show patch;
import "dart:fiber";

@pragma("vm:recognized", "other")
@pragma("vm:never-inline")
external void _coroutineInitialize(_Coroutine root);

@pragma("vm:recognized", "other")
@pragma("vm:never-inline")
external void _coroutineTransfer(_Coroutine from, _Coroutine to);

@pragma("vm:recognized", "other")
@pragma("vm:never-inline")
external void _coroutineFork(_Coroutine from, _Coroutine to);

@pragma("vm:entry-point")
class _Coroutine {
  @pragma("vm:external-name", "Coroutine_factory")
  external factory _Coroutine._(int size, void Function() entry);
  @pragma("vm:recognized", "other")
  @pragma("vm:prefer-inline")
  external _Coroutine get _caller;
}

@patch
class Fiber {
  final _Coroutine _current;
  final void Function() _entry;

  @patch
  @pragma("vm:prefer-inline")
  FiberState get state => _state;
  var _state = FiberState.created;

  @patch
  @pragma("vm:prefer-inline")
  Fiber._({required int size, required void Function() entry, required String name, bool defer = false})
      : this.name = name,
        _entry = entry,
        _current = _Coroutine._(size, defer ? _defer : _run);

  @patch
  @pragma("vm:prefer-inline")
  void _start() {
    Fiber._owner = this;
    _state = FiberState.initialized;
    _coroutineInitialize(_current);
  }

  @patch
  @pragma("vm:prefer-inline")
  void _transfer(Fiber to) {
    Fiber._owner = to;
    to._caller = this;
    _coroutineTransfer(_current, to._current);
  }

  @patch
  @pragma("vm:prefer-inline")
  void _fork(Fiber to) {
    Fiber._owner = to;
    to._caller = this;
    _coroutineFork(_current, to._current);
  }

  @pragma("vm:never-inline")
  static void _run() {
    Fiber._owner._state = FiberState.running;
    Fiber._owner._entry();
    Fiber._owner._state = FiberState.finished;
  }

  @pragma("vm:never-inline")
  static void _defer() {
    Fiber._owner._state = FiberState.running;
    Fiber._owner._transfer(Fiber._owner._caller!!);
    Fiber._owner._entry();
    Fiber._owner._state = FiberState.finished;
  }
}
