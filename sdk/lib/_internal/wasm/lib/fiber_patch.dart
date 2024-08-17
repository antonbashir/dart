import "dart:_internal" show patch;
import "dart:fiber";

@patch
class Fiber {
  @patch
  static void suspend() {
    throw Exception("suspend");
  }
}
