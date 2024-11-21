import 'dart:fiber';
import 'dart:typed_data';

void main() {
  Fiber.launch(() {
    final iterations = 100000;
    final delta = iterations * 0.1;
    var percents = 0;
    for (var i = 0; i < iterations; i++) {
      print(i.toString());
      Fiber.spawn(work1);
      Fiber.spawn(work1);
      Fiber.spawn(work1);
      
      Fiber.reschedule();
      Fiber.reschedule();
      Fiber.reschedule();
    }
    print("exit");
  });
}

@pragma("vm:never-inline")
void work1() {
  Fiber.reschedule();
  work2();
  Fiber.spawn(work2);
}

@pragma("vm:never-inline")
void work2() {
  work3();
}

@pragma("vm:never-inline")
void work3() {
  work4();
}

@pragma("vm:never-inline")
void work4() {
  work5();
}

@pragma("vm:never-inline")
void work5() {
  Uint8List.new(1 * 1024 * 1024);
}
