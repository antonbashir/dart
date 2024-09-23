part of dart.fiber;

extension type _FiberLink(_Coroutine _coroutine) {
  @pragma("vm:prefer-inline")
  factory _FiberLink._create(_Coroutine coroutine) {
    coroutine._toProcessorNext = _FiberLink(coroutine);
    coroutine._toProcessorPrevious = _FiberLink(coroutine);
    return _FiberLink(coroutine);
  }

  @pragma("vm:prefer-inline")
  _FiberLink get _previous => _coroutine._toProcessorPrevious;
  
  @pragma("vm:prefer-inline")
  set _previous(_FiberLink value) => _coroutine._toProcessorPrevious = value;

  @pragma("vm:prefer-inline")
  _FiberLink get _next => _coroutine._toProcessorNext;

  @pragma("vm:prefer-inline")
  set _next(_FiberLink value) => _coroutine._toProcessorNext = value;

  @pragma("vm:prefer-inline")
  bool get _isEmpty => identical(_next, _previous) && identical(_next, _coroutine);

  @pragma("vm:prefer-inline")
  void _stealTail(_FiberLink item) {
    item._previous._next = item._next;
    item._next._previous = item._previous;
    item._next = _FiberLink(_coroutine);
    item._previous = _previous;
    item._previous._next = item;
    item._next._previous = item;
  }

  @pragma("vm:prefer-inline")
  _FiberLink _removeHead() {
    final shift = _next;
    _next = shift._next;
    shift._next._previous = _FiberLink(_coroutine);
    shift._next = shift._previous = shift;
    return shift;
  }
}
