import "dart:fiber";
import "dart:_internal" show patch;

@patch
_Coroutine? Coroutine_create(int size, int ownerIndex, Object owner, int attributes, Function trampoline) => throw UnimplementedError();

@patch
void Coroutine_initialize(_Coroutine root) => throw UnimplementedError();

@patch
void Coroutine_transfer(_Coroutine from, _Coroutine to) => throw UnimplementedError();

@patch
void Coroutine_fork(_Coroutine from, _Coroutine to) => throw UnimplementedError();

@patch
_Coroutine? Coroutine_current() => throw UnimplementedError();

@patch
int Coroutine_getIndex(_Coroutine coroutine) => throw UnimplementedError();

@patch
int Coroutine_getOwner(_Coroutine coroutine) => throw UnimplementedError();

@patch
int Coroutine_getAttributes(_Coroutine coroutine) => throw UnimplementedError();

@patch
void Coroutine_setAttributes(_Coroutine coroutine, int attributes) => throw UnimplementedError();

@patch
_Coroutine? Coroutine_getCaller(_Coroutine coroutine) => throw UnimplementedError();

@patch
void Coroutine_setCaller(_Coroutine coroutine, _Coroutine caller) => throw UnimplementedError();
