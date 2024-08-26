import "dart:_internal" show patch;
import "dart:fiber";

@patch
class Fiber {
  @patch
  FiberState get state => _state;
  var _state = FiberState.created;
  @patch
  Fiber({required int size, required void Function() entry, required String name}) : this.name = name {}
  @patch
  void start() {}
  @patch
  void transfer(Fiber to) {}
  @patch
  void fork(Fiber to) {}
}