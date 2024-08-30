import "dart:_internal" show patch;
import "dart:fiber";
import "dart:async" show FutureOr;

const _kRootContextSize = 4096;

@pragma("vm:recognized", "other")
@pragma("vm:prefer-inline")
external void _coroutineInitialize(_Coroutine root);

@pragma("vm:recognized", "other")
@pragma("vm:prefer-inline")
external void _coroutineTransfer(_Coroutine from, _Coroutine to);

@pragma("vm:recognized", "other")
@pragma("vm:prefer-inline")
external void _coroutineFork(_Coroutine from, _Coroutine to);

@pragma("vm:entry-point")
class _Coroutine {
  @pragma("vm:external-name", "Coroutine_factory")
  external factory _Coroutine._(int size, FutureOr<void> Function() entry);
  @pragma("vm:recognized", "other")
  @pragma("vm:prefer-inline")
  external _Coroutine get _caller;
}

@patch
class Fiber {
  final _Coroutine _current;

  @patch
  FiberState get state => _state;
  var _state = FiberState.created;

  @pragma("vm:prefer-inline")
  Fiber._({required int size, required void Function() entry, required String name})
      : this.name = name,
        _current = _Coroutine._(size, entry) {}

  @patch
  @pragma("vm:prefer-inline")
  factory Fiber.main({required int size, required void Function() entry}) => Fiber._(size: size, entry: entry, name: "main");

  @patch
  @pragma("vm:prefer-inline")
  factory Fiber.child({required int size, required void Function() entry, required String name}) => Fiber._(size: size, entry: entry, name: name);

  @patch
  @pragma("vm:prefer-inline")
  void start() {
    _coroutineInitialize(_current);
  }

  @patch
  @pragma("vm:prefer-inline")
  void transfer(Fiber to) {
     _coroutineTransfer(_current, to._current);
  }

  @patch
  @pragma("vm:prefer-inline")
  void fork(Fiber to) {
    _coroutineFork(_current, to._current);
  }
}
