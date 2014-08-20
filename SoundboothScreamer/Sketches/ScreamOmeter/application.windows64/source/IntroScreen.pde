class IntroScreen{
  float frame1;
  float frame2;
  Panel panel = new Panel();
  float timer;
  int tStamp = 0;
  Boolean isActive = false;
  float startTime;

  void init(){
    panel.init();
    frame1 = 0;
    frame2 = 5;
  startTime = 10;
  }

  void update(){
    //do once
    if(!isActive){
      tStamp = millis();
      isActive=true;
      println("setIntroTimeStamp");

    }

    timer = ((millis()-tStamp)*0.001);
    if(timer>frame1 && timer<frame2){
      panel.textTitles("Welcome to the ScreamOmeter", "Show your energy!");
    }
    if(timer>frame2 && timer<startTime){
      pushMatrix();
              pushStyle();
              fill(EmSilver);
              textSize(92);
              textAlign(CENTER, CENTER);
      text("Scream to break the glass",width/2,height/2-310);
      popStyle(); 
      popMatrix();
      panel.textTitles("Try to beat the record score", nf(currentHiscore,2,2)+" sec");
      pushMatrix();
      translate(width/2, height- height/4);
      panel.drawTimerPanel(lerp(0,currentHiscore, min(1.0,(timer)-frame2)),false);
      popMatrix();
    }

if(timer>startTime){
  startSound = true;
  playGame = true;
  playIntro = false;
  println("start game");
  println(second());
}

  }

  void reset(){
    isActive = false;
  }
}
