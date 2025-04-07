import "dart:fiber";
import "dart:_internal" show patch;

@patch
@pragma("vm:external-name", "Coroutine_create")
external _Coroutine? Coroutine_create(int size, int ownerIndex, Object owner, int attributes, Function trampoline);

@patch
@pragma("vm:recognized", "other")
@pragma("vm:never-inline")
@pragma("vm:unsafe:no-interrupts")
@pragma("vm:unsafe:no-bounds-checks")
external void Coroutine_initialize(_Coroutine root);

@patch
@pragma("vm:recognized", "other")
@pragma("vm:never-inline")
@pragma("vm:unsafe:no-interrupts")
@pragma("vm:unsafe:no-bounds-checks")
external void Coroutine_transfer(_Coroutine from, _Coroutine to);

@patch
@pragma("vm:recognized", "other")
@pragma("vm:never-inline")
@pragma("vm:unsafe:no-interrupts")
@pragma("vm:unsafe:no-bounds-checks")
external void Coroutine_fork(_Coroutine from, _Coroutine to);

@patch
@pragma("vm:recognized", "other")
@pragma("vm:prefer-inline")
@pragma("vm:idempotent")
@pragma("vm:unsafe:no-interrupts")
@pragma("vm:unsafe:no-bounds-checks")
external _Coroutine? Coroutine_current();

@patch
@pragma("vm:recognized", "other")
@pragma("vm:prefer-inline")
@pragma("vm:idempotent")
@pragma("vm:unsafe:no-interrupts")
@pragma("vm:unsafe:no-bounds-checks")
external int Coroutine_getIndex(_Coroutine coroutine);

@patch
@pragma("vm:recognized", "other")
@pragma("vm:prefer-inline")
@pragma("vm:idempotent")
@pragma("vm:unsafe:no-interrupts")
@pragma("vm:unsafe:no-bounds-checks")
external int Coroutine_getAttributes(_Coroutine coroutine);

@patch
@pragma("vm:recognized", "other")
@pragma("vm:prefer-inline")
@pragma("vm:unsafe:no-interrupts")
@pragma("vm:unsafe:no-bounds-checks")
external void Coroutine_setAttributes(_Coroutine coroutine, int attributes);

@patch
@pragma("vm:recognized", "other")
@pragma("vm:prefer-inline")
@pragma("vm:idempotent")
@pragma("vm:unsafe:no-interrupts")
@pragma("vm:unsafe:no-bounds-checks")
external _Coroutine? Coroutine_getCaller(_Coroutine coroutine);

@patch
@pragma("vm:recognized", "other")
@pragma("vm:prefer-inline")
@pragma("vm:unsafe:no-interrupts")
@pragma("vm:unsafe:no-bounds-checks")
external void Coroutine_setCaller(_Coroutine coroutine, _Coroutine caller);

@patch
@pragma("vm:recognized", "other")
@pragma("vm:prefer-inline")
@pragma("vm:idempotent")
@pragma("vm:unsafe:no-interrupts")
@pragma("vm:unsafe:no-bounds-checks")
external int Coroutine_getOwner(_Coroutine coroutine);
