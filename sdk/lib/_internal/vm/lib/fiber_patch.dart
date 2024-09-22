import "dart:_internal" show patch;
import "dart:fiber";

@patch
@pragma("vm:entry-point")
class _Coroutine {
  @patch
  @pragma("vm:external-name", "Coroutine_factory")
  external factory _Coroutine._(int size, Function trampoline);

  @patch
  @pragma("vm:recognized", "other")
  @pragma("vm:prefer-inline")
  external String get _name;
  @patch
  @pragma("vm:recognized", "other")
  @pragma("vm:prefer-inline")
  external set _name(String value);

  @patch
  @pragma("vm:recognized", "other")
  @pragma("vm:prefer-inline")
  external int get _index;
  @patch
  @pragma("vm:recognized", "other")
  @pragma("vm:prefer-inline")
  external set _index(int value);

  @patch
  @pragma("vm:recognized", "other")
  @pragma("vm:prefer-inline")
  external void Function() get _entry;
  @patch
  @pragma("vm:recognized", "other")
  @pragma("vm:prefer-inline")
  external set _entry(void Function() value);

  @patch
  @pragma("vm:recognized", "other")
  @pragma("vm:prefer-inline")
  external void Function() get _trampoline;
  @patch
  @pragma("vm:recognized", "other")
  @pragma("vm:prefer-inline")
  external set _trampoline(void Function() value);

  @patch
  @pragma("vm:recognized", "other")
  @pragma("vm:prefer-inline")
  external List get _arguments;
  @patch
  @pragma("vm:recognized", "other")
  @pragma("vm:prefer-inline")
  external set _arguments(List value);

  @patch
  @pragma("vm:recognized", "other")
  @pragma("vm:prefer-inline")
  external int get _attributes;
  @patch
  @pragma("vm:recognized", "other")
  @pragma("vm:prefer-inline")
  external set _attributes(int value);

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
  external _Coroutine? get _scheduler;
  @patch
  @pragma("vm:recognized", "other")
  @pragma("vm:prefer-inline")
  external set _scheduler(_Coroutine? value);

  @patch
  @pragma("vm:recognized", "other")
  @pragma("vm:prefer-inline")
  external _FiberProcessor get _processor;
  @patch
  @pragma("vm:recognized", "other")
  @pragma("vm:prefer-inline")
  external set _processor(_FiberProcessor value);

  @patch
  @pragma("vm:recognized", "other")
  @pragma("vm:prefer-inline")
  external _FiberLink get _toProcessor;
  @patch
  @pragma("vm:recognized", "other")
  @pragma("vm:prefer-inline")
  external set _toProcessor(_FiberLink value);

  @patch
  @pragma("vm:recognized", "other")
  @pragma("vm:never-inline")
  external static _Coroutine _at(int index);
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

  @patch
  @pragma("vm:recognized", "other")
  @pragma("vm:prefer-inline")
  @pragma("vm:idempotent")
  external static _Coroutine? get _current;
}
