import "dart:_internal" show patch;
import "dart:fiber";

@patch
@pragma("vm:entry-point")
class _Coroutine {
  @patch
  @pragma("vm:external-name", "Coroutine_factory")
  external factory _Coroutine._(int size, void Function() entry, void Function() trampoline);
  @patch
  @pragma("vm:recognized", "other")
  @pragma("vm:prefer-inline")
  external set _state(int value);
  @patch
  @pragma("vm:recognized", "other")
  @pragma("vm:prefer-inline")
  external int get _state;
  @patch
  @pragma("vm:recognized", "other")
  @pragma("vm:prefer-inline")
  external _Coroutine? get _caller;
  @patch
  @pragma("vm:recognized", "other")
  @pragma("vm:prefer-inline")
  external set _caller(_Coroutine? value);
  @patch
  @pragma("vm:recognized", "other")
  @pragma("vm:prefer-inline")
  external void Function() get _entry;
  @patch
  @pragma("vm:recognized", "other")
  @pragma("vm:prefer-inline")
  external static _Coroutine? get _current;
  @patch
  @pragma("vm:recognized", "other")
  @pragma("vm:never-inline")
  external static void _initialize(_Coroutine root);
  @patch
  @pragma("vm:recognized", "other")
  @pragma("vm:never-inline")
  external static void _transfer(_Coroutine from, _Coroutine to);
  @patch
  @pragma("vm:recognized", "other")
  @pragma("vm:never-inline")
  external static void _fork(_Coroutine from, _Coroutine to);
}
