part of dart.fiber;

class _FiberPool {
  final List<Fiber?> _fibers = [];

  var _next = 0;

  Fiber allocate() {
    final fiber = Fiber(_fibers.length);
    _fibers.add(fiber);
    return fiber;
  }

  Fiber get(int index) => _fibers[index]!;

  void free(int index) => _fibers[index] = null;

  void clear() => _fibers.clear();
}

final _pool = _FiberPool();