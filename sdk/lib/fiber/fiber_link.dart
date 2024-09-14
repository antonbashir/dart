part of dart.fiber;

class _FiberLink {
  late final Fiber _value;
  late _FiberLink _previous;
  late _FiberLink _next;

  @pragma("vm:prefer-inline")
  _FiberLink() {
    _next = this;
    _previous = this;
  }

  @pragma("vm:prefer-inline")
  bool get isEmpty => identical(_next, _previous) && identical(_next, this);
  
  @pragma("vm:prefer-inline")
  _FiberLink get first => _next;

  @pragma("vm:prefer-inline")
  void remove() {
    _previous._next = _next;
    _next._previous = _previous;
    _next = this;
    _previous = this;
  }

  @pragma("vm:prefer-inline")
  void addTail(_FiberLink item) {
    item._next = this;
    item._previous = _previous;
    item._previous._next = item;
    item._next._previous = item;
  }

  @pragma("vm:prefer-inline")
  void add(_FiberLink item) {
    item._previous = this;
    item._next = _next;
    item._previous._next = item;
    item._next._previous = item;
  }

  @pragma("vm:prefer-inline")
  void steal(_FiberLink from) {
    from.remove();
    add(from);
  }

  @pragma("vm:prefer-inline")
  void forEach(void Function(_FiberLink link) iterator) {
    for (var item = _next; _next != this; _next = _next._next) iterator(item);
  }

  @pragma("vm:prefer-inline")
  _FiberLink removeHead() {
    final shift = _next;
    _next = shift._next;
    shift._next._previous = this;
    shift._next = shift._previous = shift;
    return shift;
  }
}
