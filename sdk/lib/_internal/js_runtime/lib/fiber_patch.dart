import "dart:_internal" show patch;
import "dart:fiber";

@patch
class Fiber {
  @patch
  FiberState get state => _state;
  var _state = FiberState.created;
  Fiber._(this.name);
  @patch
  @pragma("vm:never-inline")
  factory Fiber.main({required int size, required void Function() entry}) => Fiber._("fiber");
  @patch
  @pragma("vm:never-inline")
  factory Fiber.child({required int size, required void Function() entry, required String name}) => Fiber._("fiber");
  @patch
  void start() {
    throw UnsupportedError("Fiber.start")
  }
  @patch
  void transfer(Fiber to) {
    throw UnsupportedError("Fiber.transfer")
  }
  @patch
  void fork(Fiber to) {
    throw UnsupportedError("Fiber.fork")
  }
}
