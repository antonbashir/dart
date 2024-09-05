import "dart:_internal" show patch;
import "dart:fiber";

@patch
class Fiber {
  @patch
  FiberState get state => _state;
  var _state = FiberState.created;
  @patch
  Fiber._({required int size, required void Function() entry, required String name}) : this.name = name;
  @patch
  void start() { throw UnsupportedError("Fiber.start"); }
  @patch
  void transfer(Fiber to) { throw UnsupportedError("Fiber.transfer"); }
  @patch
  void fork(Fiber to) { throw UnsupportedError("Fiber.fork"); }
  @patch
  static void idle() { throw UnsupportedError("Fiber.idle"); }
}
