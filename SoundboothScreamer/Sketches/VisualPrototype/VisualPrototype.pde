PFont font;
Panel panel = new Panel();

public float timer;
int initTime;

void setup() {

  size(1280, 1040, P2D);
  font = createFont("GillSans", 48);
  textFont(font);
  textAlign(CENTER, CENTER);
  panel.init(width/4, height);

initTime = millis()+60000; //60 seconds
}

void draw() {

  background(0);
  panel.update();
  update();

}

void update(){
  timer = initTime-millis();
}
