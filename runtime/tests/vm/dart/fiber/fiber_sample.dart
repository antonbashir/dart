import 'dart:fiber';

var commonState = "";

void main() {
  print("before start");
  Fiber.launch(mainEntry, terminate: false);
  print("after start");
}

void mainEntry() {
  print("main: entry");
  commonState += "main -> ";
  Fiber.spawn(childEntry);
  commonState += "main -> ";
  print("main: after child transfer");
  Fiber.reschedule();
  print(commonState);
}

void childEntry() {
  print("child: entry");
  commonState += "child -> ";
  Fiber.reschedule();
  commonState += "child";
}
