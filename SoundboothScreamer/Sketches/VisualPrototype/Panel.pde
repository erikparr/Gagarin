class Panel {
  int w,h;

  void init(int width, int height){
    w= width;
    h= height;
    rectMode(CORNER);
    textAlign(LEFT, CENTER);

  }

  void update(){

fill(EmGrey);
    noStroke();
rect(0,0,w+51,h);

    textBox();
    fill(200,200,200);
    textSize(96);
    text((int)VisualPrototype.tempFreq, 100, h/2);

    fill(EmGrey);
    noStroke();
    rect(w,0,50,h); // sidebar

    setGradient(w,0+150,50,h/2-150,EmGrey,EmRed);
    setGradient(w,h/2,50,h/2-150,EmRed,EmGrey);
    stroke(200);
    strokeWeight(1);
    line(w+115,0,w+115,height);
  }

  void textBox(){
    int px = 0;
    int py = h-h/3;
    int wd = w;
    int ht = 70;
    textSize(52);

    fill(65*0.8,70*0.8,80*0.8);
    noStroke();
    rect(px,py-70,wd,h/3);
    noFill();
    stroke(0);
rect(px,py-70,wd,h/3,7);

    fill(200,200,200);
    text("Countdown: "+ (int)timer/1000, px,py-(ht/2));
    // text(mouseX +" "+mouseY,20,20);
    // text(sin(millis()*mouseX),20,40);
    stopwatch(wd/2, h-(h/5), 225,225);
  }

  // void freqChart(int px, int py){
  // rect(px,py,wd,ht);
  //
  // }
  void setGradient(int x, int y, float w, float h, color c1, color c2 ) {

    noFill();

    for (int i = y; i <= y+h; i++) {
      float inter = map(i, y, y+h, 0, 1);
      color c = lerpColor(c1, c2, inter);
      stroke(c);
      strokeWeight(1);
      line(x, i, x+w, i);
      if(i%(height/20)==0){
        if(i%(height/5)==0)
        strokeWeight(2.0);
        else if(i%(height/10)==0)
        strokeWeight(1.0);
        else
        strokeWeight(0.5);
        stroke(0);
        line(x+(w/2), i, x+w, i);
      }
      if(i==height/2){
        strokeWeight(10.0);
        stroke(0);
        line(x+(w/2), i, x+w, i);
      }
    }

  }

  void stopwatch(int px, int py, int wd, int ht){
    float offset = (1.5*PI);
    fill(50,50,50);
    ellipse(px, py, wd, ht);
    fill(EmBlue);

    arc(px, py, wd, ht, 0+offset, map(VisualPrototype.this.timer, 0, 60000, 0+offset, (2*PI)+offset), PIE);
  }

}
