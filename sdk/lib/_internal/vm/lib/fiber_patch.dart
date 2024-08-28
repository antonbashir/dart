import "dart:_internal" show patch;
import "dart:fiber";
import "dart:async" show FutureOr;

const _kRootContextSize = 4096;

@pragma("vm:recognized", "other")
@pragma("vm:external-name", "Fiber_coroutineInitialize")
external void _coroutineInitialize(_Coroutine root);

@pragma("vm:recognized", "other")
@pragma("vm:external-name", "Fiber_coroutineTransfer")
external void _coroutineTransfer(_Coroutine from, _Coroutine to);

@pragma("vm:entry-point")
class _Coroutine {
  @pragma("vm:external-name", "Coroutine_factory")
  external factory _Coroutine._(int size);
  @pragma("vm:recognized", "other")
  @pragma("vm:prefer-inline")
  external _Coroutine get _caller;
}

@patch
class Fiber {
  final void Function() _entry;
  _Coroutine _root = _Coroutine._(_kRootContextSize);
  _Coroutine _current;

  @patch
  FiberState get state => _state;
  var _state = FiberState.created;

  @pragma("vm:prefer-inline")
  Fiber._({required int size, required void Function() entry, required String name})
      : this.name = name,
        _entry = entry,
        _current = _Coroutine._(size) {}

  @pragma("vm:prefer-inline")
  void _construct() {
    _coroutineInitialize(_root);
    if (_state == FiberState.created) {
      _state = FiberState.initialized;
      _launch();
    }
  }

  @patch
  @pragma("vm:never-inline")
  factory Fiber.main({required int size, required void Function() entry}) {
    Fiber._main = Fiber._(size: size, entry: entry, name: "main").._construct();
    return Fiber._main;
  }

  @patch
  @pragma("vm:never-inline")
  factory Fiber.child({required int size, required void Function() entry, required String name}) => Fiber._(size: size, entry: entry, name: name).._construct();

  @pragma("vm:never-inline")
  void _launch() {
    print("_launch");
    _coroutineTransfer(_current, _root);
    print("_coroutineTransfer");
    _state = FiberState.running;
    _entry();
    _state = FiberState.finished;
    _coroutineTransfer(_current, Fiber._main == this ? _root : _current._caller);
  }

  @patch
  @pragma("vm:prefer-inline")
  void start() {
    if (_state == FiberState.initialized) {
      _coroutineTransfer(_root, _current);
    }
  }

  @patch
  @pragma("vm:prefer-inline")
  void transfer(Fiber to) {
    _coroutineTransfer(_current, to._current);
  }

  @patch
  @pragma("vm:prefer-inline")
  void fork(Fiber to) {
    if (to._state == FiberState.initialized) {
      to._root = _current;
      to.start();
    }
  }
}
