class Panel {
  int w,h;

  void init(float width, float height){
    w= (int)width;
    h= (int)height;
    rectMode(CORNER);
    textAlign(LEFT, CENTER);

  }

  void update(){

    fill(0);
    noStroke();
    rect(0,0,w+51,h);

    textBox("Countdown: ", w/2, h/2, 92);
    stopwatch(w/2, h-(h/5), 225,225);

    fill(200,200,200);
    textSize(96);
    text((int)tempFreq, 100, h/2);

    fill(EmSilver);
    noStroke();
    rect(w+15,0,100,h); // sidebar

    setGradient(w+15,0+150,100,h/2-150,EmSilver,EmRed);
    setGradient(w+15,h/2,100,h/2-150,EmRed,EmSilver);
    stroke(200);
    strokeWeight(1);
    line(w+115,0,w+115,height);
  }

  void textBox(String text, int px, int py, int textSize){
    textSize(textSize);
    fill(EmGrey);
    noStroke();
    rect(px,py,textWidth(text),textSize+(textSize*0.2));
    noFill();
    stroke(0);
    rect(px,py,textWidth(text),textSize+(textSize*0.2),7);

    fill(EmRed);
    text(text + (int)timer/1000, px,py);
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

  void stopwatch(int px, int py, int wd, int ht){
    float offset = (1.5*PI);
    fill(50,50,50);
    ellipse(px, py, wd, ht);
    fill(EmBlue);

    arc(px, py, wd, ht, 0+offset, map(VisualPrototype.this.timer, 0, 60000, 0+offset, (2*PI)+offset), PIE);
  }

}
