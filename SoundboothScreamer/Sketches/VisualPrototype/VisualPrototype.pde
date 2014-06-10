import processing.pdf.*;

void setup() {
  size(1280, 1040, P2D, "TypeDemo.pdf");
  textMode(SHAPE);
  textSize(180);
}

void draw() {
  background(0);
  text("ABC", 75, 350);
}
