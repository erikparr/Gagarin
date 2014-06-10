class Panel {
  int w,h;

  void init(int width, int height){
    w= width;
    h= height;
    rectMode(CORNER);
    textAlign(LEFT, CENTER);

  }

  void update(){
    fill(100);
    noStroke();
    rect(0,0,w,h);
    textBox();
  }

  void textBox(){
    int px = 0;
    int py = h/8;
    int wd = w;
    int ht = 70;
    fill(50);
    noStroke();
    rect(px,py,wd,ht);
    fill(180,20,0);
    text("Countdown: "+ (int)VisualPrototype.this.timer/1000, px,py+(ht/2));
stopwatch(wd/2, h/3, 225,225);
  }

  void stopwatch(int px, int py, int wd, int ht){
    float offset = (1.5*PI);
    fill(200,0,0);
ellipse(px, py, wd, ht);
    fill(50,50,50);
arc(px, py, wd, ht, 0+offset, map(VisualPrototype.this.timer, 0, 60000, 0, (2*PI)+offset), PIE);
  }

}
