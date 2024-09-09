import "dart:_internal" show patch;
import "dart:fiber";

@patch
class Fiber {
  @patch
  FiberState get state => _state;
  var _state = FiberState.created;
  @patch
  Fiber._({required int size, required void Function() entry, required String name, bool defer = false}) : this.name = name;
  @patch
  void _start() { throw UnsupportedError("Fiber.start"); }
  @patch
  void _transfer(Fiber to) { throw UnsupportedError("Fiber.transfer"); }
  @patch
  void _fork(Fiber to) { throw UnsupportedError("Fiber.fork"); }
}
