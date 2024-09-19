import "dart:_internal" show patch;
import "dart:fiber";

@patch
class _Coroutine {
  @patch
  factory _Coroutine._(int size) => throw UnsupportedError("_Coroutine._");
  @patch
  String get _name => throw UnsupportedError("_Coroutine._current");
  @patch
  set _name(String value) => throw UnsupportedError("_Coroutine._current");
  @patch
  void Function() get _entry => throw UnsupportedError("_Coroutine._current");
  @patch
  set _entry(void Function() value) => throw UnsupportedError("_Coroutine._current");
  @patch
  void Function() get _trampoline => throw UnsupportedError("_Coroutine._current");
  @patch
  set _trampoline(void Function() value) => throw UnsupportedError("_Coroutine._current");
  @patch
  List get _arguments => throw UnsupportedError("_Coroutine._current");
  @patch
  set _arguments(List value) => throw UnsupportedError("_Coroutine._current");
  @patch
  int get _attributes => throw UnsupportedError("_Coroutine._current");
  @patch
  set _attributes(int value) => throw UnsupportedError("_Coroutine._current");
  @patch
  _Coroutine? get _caller => throw UnsupportedError("_Coroutine._current");
  @patch
  set _caller(_Coroutine? value) => throw UnsupportedError("_Coroutine._current");
  @patch
  _Coroutine? get _scheduler => throw UnsupportedError("_Coroutine._current");
  @patch
  set _scheduler(_Coroutine? value) => throw UnsupportedError("_Coroutine._current");
  @patch
  FiberProcessor get _processor => throw UnsupportedError("_Coroutine._current");
  @patch
  set _processor(FiberProcessor value) => throw UnsupportedError("_Coroutine._current");
  @patch
  _FiberLink get _toProcessor => throw UnsupportedError("_Coroutine._current");
  @patch
  set _toProcessor(_FiberLink value) => throw UnsupportedError("_Coroutine._current");
  @patch
  static _Coroutine? get _current => throw UnsupportedError("_Coroutine._current");
  @patch
  static void _initialize(_Coroutine root) => throw UnsupportedError("_Coroutine._initialize");
  @patch
  static void _transfer(_Coroutine from, _Coroutine to) => throw UnsupportedError("_Coroutine._transfer");
  @patch
  static void _fork(_Coroutine from, _Coroutine to) => throw UnsupportedError("_Coroutine._fork");
}
