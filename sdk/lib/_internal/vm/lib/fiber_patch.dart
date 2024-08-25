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

@pragma("vm:recognized", "other")
@pragma("vm:external-name", "Fiber_coroutineExit")
external void _coroutineExit();

@pragma("vm:entry-point")
void _coroutineLaunch(_Coroutine from, _Coroutine to) {
  print("_coroutineLaunch");
  final entry = to._entry;
  print(entry);
  _coroutineTransfer(to, from);
//  print("_coroutineLaunch -> _coroutineTransfer");
  print(from);
  print(to);
  print(entry);
  entry();
  print("_coroutineLaunch -> _currentEntry");
  // _coroutineTransfer(from, to);
}

@pragma("vm:entry-point")
class _Coroutine {
  @pragma("vm:external-name", "Coroutine_factory")
  external factory _Coroutine._(int size, void Function()? entry);
  @pragma("vm:recognized", "other")
  @pragma("vm:prefer-inline")
  external void Function() get _entry;
}

@patch
class Fiber {
  final _Coroutine _current;
  final _Coroutine _root = _Coroutine._(_kRootContextSize, null);
  
  @patch
  FiberState get state => _state;
  var _state = FiberState.created;

  @patch
  Fiber({required int size, required void Function() entry, required String name}): this.name = name, _current = _Coroutine._(size, entry);

  @patch
  @pragma("vm:never-inline")
  void construct() {
    print("$name: fiber._construct");
    _coroutineInitialize(_root, _current);
    print("$name: fiber._construct -> _coroutineInitialize");
    _state = FiberState.initialized;
  }

  @patch
  @pragma("vm:prefer-inline")
  void start() {
    print("$name: fiber.start");
    if (_state == FiberState.initialized) {
      _state = FiberState.running;
      _coroutineTransfer(_root, _current);
      print("$name: fiber.start -> _coroutineTransfer");
      _state = FiberState.finished;
    }
  }

  @patch
  @pragma("vm:prefer-inline")
  void transfer(Fiber to) {
      print("$name: fiber.transfer");
    _coroutineTransfer(_current, to._current);
      print("$name: fiber.transfer -> _coroutineTransfer");
  }

}
