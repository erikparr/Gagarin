class Panel {

  void init(){
    rectMode(CORNER);
    textAlign(LEFT, CENTER);
  }

  void updateWindow(float width, float height){
    int w= (int)width;
    int h= (int)height;
    noFill();
    stroke(EmSilver);
    rect(0,0,w+51,h,7);

  }

  void updateSidebar(float width, float height){
    int w= (int)width;
    int h= (int)height;
    fill(EmSilver);
    noStroke();
    rect(w+15,0,100,h); // sidebar

  }

  void updateGradient(float width, float height, color color1, color color2){
    int w= (int)width;
    int h= (int)height;
    setGradient(w+15,0+150,100,h/2-150,color1,color2);
    setGradient(w+15,h/2,100,h/2-150,color2,color1);
    // setGradient(w+15,0+150,100,h/2-150,EmSilver,EmRed);
    // setGradient(w+15,h/2,100,h/2-150,EmRed,EmSilver);

  }

  // void update(){
  //   updateStopwatch(w/2, h-(h/5), 225,225);
  // }

  void textBox(String text, int w, int h, int textSize, int numLines){
    int offset = 40;
    int wd = 3;
    textSize(textSize);
    stroke(EmBlue);
    strokeWeight(3);
    noFill();
    rect(-offset/2,-offset/2,w+offset,h,7);
    fill(EmGrey);
    noStroke();
    rect(-offset/2+(wd/2),-offset/2+(wd/2),w+offset-wd,h-wd,7);

fill(255);
    text(text,0,0,w,h);
    // text(mouseX +" "+mouseY,20,20);
    // text(sin(millis()*mouseX),20,40);
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

  void updateStopwatch(float timescale, int w, int h){
    float offset = (1.5*PI);
    fill(50,50,50);
    ellipse(0, 0, w, h);
    fill(EmBlue);
    arc(0, 0, w, h, 0+offset, map(timescale, 0, 60000, 0+offset, (2*PI)+offset), PIE);
  }

}
