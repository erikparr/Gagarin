class Panel {
  PImage logo;
  PImage logoMsk;
  // CamGrab camera = new CamGrab();

  void init(){
    rectMode(CORNER);
    textAlign(LEFT, CENTER);
    // camera.init();
    logo = loadImage("logoSm.jpg");  // Load an image into the program
    logoMsk = loadImage("logoSmMsk3.jpg");  // Load an image into the program
    logo.mask(logoMsk);
  }

  void updateWindow(float width, float height, Boolean highlight){
    int w= (int)width;
    int h= (int)height;
    noStroke();
    fill(EmSilver);
    rect(0,0,w,h);
    textSize(46);
    fill(EmRed);
    text("HIGHSCORE: 1:52",width/20,height/10);
    // image(logo,-20,-20);
    // camera.update();
    if(highlight){
      fill(0,0,0,150);
      rect(0,0,w,h);
    }
  }

  void textTitles(String subTitle, String title){
    pushStyle();
    textAlign(CENTER);
    fill(205);
    textSize(64);
    text(subTitle, width/2, height/2 - (height/5));
    textSize(136);
    text(title, width/2, height/2);
    popStyle();
  }

  void textByline(String text){

  }


  void updateSidebar(float width, float height){
    int w= (int)width;
    int h= (int)height;
    fill(EmSilver);
    noStroke();
    rect(w+15,0,100,h); // sidebar

  }


  void wavePanel(){
    pushStyle();
    strokeWeight(2.5);  // Thicker
    pushMatrix();
    translate(0, height/2);
    tWave.update(true);
    pushMatrix();
    translate(0,freqVal);
    wave.update();
    popMatrix();
    popMatrix();
    fill(EmSilver);
    textSize(42);
    text(" Time left:", width/12, (height)-(height/4));
    textSize(136);
    text((int)timer, width/12, (height)-(height/4)+(height/10));
    textSize(92);
    text(" sec", width/5.5, (height)-(height/4)+(height/8));
    image(logo,width -(width/4), (height)-(height/4)+(height/10));
    popStyle();
  }

  void waveWindow(Boolean highlight){
    stroke(EmSilver);
    // noFill();
    // strokeWeight(3);
    // rect(0,0,width*0.658,height*0.78);
    fill(0);
    noStroke();
    rect(0,0,width*0.658,height*0.78);
    if(highlight){
      fill(0,155);
      rect(0,0,width*0.658,height*0.78);
    }
  }

  void textBox(String text, int w, int h, int textSize, int numLines){
    int offset = 40;
    int wd = 3;
    textSize(textSize);
    // stroke(EmBlue);
    // strokeWeight(3);
    // noFill();
    // rect(-offset/2,-offset/2,w+offset,h,7);
    pushMatrix();

    pushMatrix();
    translate(w/45,w/45);
    fill(EmSilver);
    noStroke();
    rect(-offset/2+(wd/2),(wd/2),w+offset-wd,h-wd+15);
    popMatrix();
    fill(EmBlue);
    noStroke();
    rect(-offset/2+(wd/2),(wd/2),w+offset-wd,h-wd+15);

    fill(255);
    text(text,0,0,w,h);
    // text(mouseX +" "+mouseY,20,20);
    // text(sin(millis()*mouseX),20,40);
    popMatrix();
  }

  // void freqChart(int px, int py){
  // rect(px,py,wd,ht);
  //
  // }

  void drawTimerPanel(float currentTime){
    pushStyle();
    noStroke();
    float offset = (1.5*PI);
    fill(EmLiteBlue);
    ellipse(0,0,225,225);
    fill(255);
    arc(0,0, 225, 225, 0+offset, map(currentTime, 90, 0,(2*PI)+offset, 0+offset), PIE);
    fill(EmBlueGrad);
    ellipse(0,0,100,100);
    popStyle();
  }
}
