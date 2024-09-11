import "dart:_internal" show patch;
import "dart:fiber";

@patch
class _Coroutine {
  @patch
  factory _Coroutine._(int size, void Function() entry, void Function() trampoline) => throw UnsupportedError("_Coroutine._");
  @patch
  set _state(int value) => throw UnsupportedError("_Coroutine._state");
  @patch
  int get _state => throw UnsupportedError("_Coroutine._state");
  @patch
  _Coroutine? get _caller => throw UnsupportedError("_Coroutine._caller");
  @patch
  set _caller(_Coroutine? value) => throw UnsupportedError("_Coroutine._caller");
  @patch
  void Function() get _entry => throw UnsupportedError("_Coroutine._entry");
  @patch
  static _Coroutine? get _current => throw UnsupportedError("_Coroutine._current");
  @patch
  static void _initialize(_Coroutine root) => throw UnsupportedError("_Coroutine._initialize");
  @patch
  static void _transfer(_Coroutine from, _Coroutine to) => throw UnsupportedError("_Coroutine._transfer");
  @patch
  static void _fork(_Coroutine from, _Coroutine to) => throw UnsupportedError("_Coroutine._fork");
  @patch
  void _recycle() => throw UnsupportedError("_Coroutine._recycle");
}
