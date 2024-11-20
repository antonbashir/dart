import 'dart:fiber';
import 'dart:typed_data';

void main() {
  Fiber.launch(() {
    final iterations = 100000;
    final delta = iterations * 0.1;
    var percents = 0;
    for (var i = 0; i < iterations; i++) {
      print(i.toString());
      Fiber.spawn(() => Uint8List.new(1 * 1024 * 1024));
      if (i == (percents + delta).truncate()) {
        percents = i;
        print("Finished: ${percents / iterations * 100}%");
      }
    }
    print("exit");
  });
}
