import "dart:fiber";
import "dart:_internal" show patch;

@patch
@pragma("vm:external-name", "Coroutine_create")
external _Coroutine? _Coroutine_create(int size, int ownerIndex, Object owner, int attributes, Function trampoline);

@patch
@pragma("vm:external-name", "Coroutine_idle")
external void _Coroutine_idle(int timeout);

@patch
@pragma("vm:recognized", "other")
@pragma("vm:never-inline")
@pragma("vm:unsafe:no-interrupts")
@pragma("vm:unsafe:no-bounds-checks")
external void _Coroutine_initialize(_Coroutine root);

@patch
@pragma("vm:recognized", "other")
@pragma("vm:never-inline")
@pragma("vm:unsafe:no-interrupts")
@pragma("vm:unsafe:no-bounds-checks")
external void _Coroutine_transfer(_Coroutine from, _Coroutine to);

@patch
@pragma("vm:recognized", "other")
@pragma("vm:never-inline")
@pragma("vm:unsafe:no-interrupts")
@pragma("vm:unsafe:no-bounds-checks")
external void _Coroutine_fork(_Coroutine from, _Coroutine to);

@patch
@pragma("vm:recognized", "other")
@pragma("vm:prefer-inline")
@pragma("vm:idempotent")
@pragma("vm:unsafe:no-interrupts")
@pragma("vm:unsafe:no-bounds-checks")
external _Coroutine? _Coroutine_current();

@patch
@pragma("vm:recognized", "other")
@pragma("vm:prefer-inline")
@pragma("vm:idempotent")
@pragma("vm:unsafe:no-interrupts")
@pragma("vm:unsafe:no-bounds-checks")
external int _Coroutine_getIndex(_Coroutine coroutine);

@patch
@pragma("vm:recognized", "other")
@pragma("vm:prefer-inline")
@pragma("vm:idempotent")
@pragma("vm:unsafe:no-interrupts")
@pragma("vm:unsafe:no-bounds-checks")
external int _Coroutine_getAttributes(_Coroutine coroutine);

@patch
@pragma("vm:recognized", "other")
@pragma("vm:prefer-inline")
@pragma("vm:unsafe:no-interrupts")
@pragma("vm:unsafe:no-bounds-checks")
external void _Coroutine_setAttributes(_Coroutine coroutine, int attributes);

@patch
@pragma("vm:recognized", "other")
@pragma("vm:prefer-inline")
@pragma("vm:idempotent")
@pragma("vm:unsafe:no-interrupts")
@pragma("vm:unsafe:no-bounds-checks")
external _Coroutine? _Coroutine_getCaller(_Coroutine coroutine);

@patch
@pragma("vm:recognized", "other")
@pragma("vm:prefer-inline")
@pragma("vm:unsafe:no-interrupts")
@pragma("vm:unsafe:no-bounds-checks")
external void _Coroutine_setCaller(_Coroutine coroutine, _Coroutine caller);

@patch
@pragma("vm:recognized", "other")
@pragma("vm:prefer-inline")
@pragma("vm:idempotent")
@pragma("vm:unsafe:no-interrupts")
@pragma("vm:unsafe:no-bounds-checks")
external int _Coroutine_getOwner(_Coroutine coroutine);
