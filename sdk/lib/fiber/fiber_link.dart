part of dart.fiber;

class _FiberLink {
  final Fiber _value;
  late _FiberLink _previous;
  late _FiberLink _next;

  @pragma("vm:prefer-inline")
  _FiberLink(this._value) {
    _next = this;
    _previous = this;
  }

  @pragma("vm:prefer-inline")
  bool get _isEmpty => identical(_next, _previous) && identical(_next, this);

  @pragma("vm:prefer-inline")
  void _stealTail(_FiberLink item) {
    item._previous._next = item._next;
    item._next._previous = item._previous;
    item._next = this;
    item._previous = _previous;
    item._previous._next = item;
    item._next._previous = item;
  }

  @pragma("vm:prefer-inline")
  _FiberLink _removeHead() {
    final shift = _next;
    _next = shift._next;
    shift._next._previous = this;
    shift._next = shift._previous = shift;
    return shift;
  }
}
