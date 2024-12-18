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
  external int get _size;

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
  external Object? get _argument;
  @patch
  @pragma("vm:recognized", "other")
  @pragma("vm:prefer-inline")
  external set _argument(Object? value);

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
  external _Coroutine get _caller;
  @patch
  @pragma("vm:recognized", "other")
  @pragma("vm:prefer-inline")
  external set _caller(_Coroutine value);

  @patch
  @pragma("vm:recognized", "other")
  @pragma("vm:prefer-inline")
  external _Coroutine get _scheduler;
  @patch
  @pragma("vm:recognized", "other")
  @pragma("vm:prefer-inline")
  external set _scheduler(_Coroutine value);

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
  external _Coroutine get _toProcessorNext;

  @patch
  @pragma("vm:recognized", "other")
  @pragma("vm:prefer-inline")
  external set _toProcessorNext(_Coroutine value);

  @patch
  @pragma("vm:recognized", "other")
  @pragma("vm:prefer-inline")
  external _Coroutine get _toProcessorPrevious;

  @patch
  @pragma("vm:recognized", "other")
  @pragma("vm:prefer-inline")
  external set _toProcessorPrevious(_Coroutine value);

  @patch
  @pragma("vm:recognized", "other")
  @pragma("vm:never-inline")
  @pragma("vm:unsafe:no-interrupts")
  @pragma("vm:unsafe:no-bounds-checks")
  external static void _initialize(_Coroutine root);

  @patch
  @pragma("vm:recognized", "other")
  @pragma("vm:never-inline")
  @pragma("vm:unsafe:no-interrupts")
  @pragma("vm:unsafe:no-bounds-checks")
  external static void _transfer(_Coroutine from, _Coroutine to);

  @patch
  @pragma("vm:recognized", "other")
  @pragma("vm:never-inline")
  @pragma("vm:unsafe:no-interrupts")
  @pragma("vm:unsafe:no-bounds-checks")
  external static void _fork(_Coroutine from, _Coroutine to);

  @patch
  @pragma("vm:recognized", "other")
  @pragma("vm:prefer-inline")
  @pragma("vm:idempotent")
  @pragma("vm:unsafe:no-interrupts")
  @pragma("vm:unsafe:no-bounds-checks")
  external static _Coroutine? get _current;

  @patch
  @pragma("vm:recognized", "other")
  @pragma("vm:prefer-inline")
  @pragma("vm:idempotent")
  @pragma("vm:unsafe:no-interrupts")
  @pragma("vm:unsafe:no-bounds-checks")
  external static List<_Coroutine> get _registry;
}
