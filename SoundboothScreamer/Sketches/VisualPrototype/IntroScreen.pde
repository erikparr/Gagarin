class IntroScreen{
  float frame1;
  float frame2;
  Panel panel = new Panel();
Boolean active = false;
Boolean isActive = false;
float timer;
int tStamp = 0;
Boolean isFinished = false;
  void init(){
    panel.init();
    frame1 = 0;
    frame2 = startTime-5;
  }

  void update(){
    //do once
    if(!isActive){
      tStamp = millis();
      isActive=true;
      println("setTimeStamp");

    }

    timer = ((millis()-tStamp)*0.001);
    if(timer>frame1 && timer<frame2){
      panel.textTitles("Welcome to the ScreamOmeter", "Show your energy!");
    }
    if(timer>frame2 && timer<startTime){
      panel.textTitles("Try to beat the high score", currentHiscore+" sec");
      pushMatrix();
      translate(width/2, height- height/4);
      panel.drawTimerPanel(lerp(0,currentHiscore, min(1.0,(timer)-frame2)));
      popMatrix();
    }

  }
  void setActive(){
    active = true;
  }
Boolean isFinished(){
  return isFinished;
}

  boolean isActive(){
    //introScreen is active while timer is less than start time
    if(timer>startTime && active == true){
       active = false;
       isFinished = true;
       startSound = true;
       tStampPlay = millis();
       println("!!!!!");
      }
      return active;
    }

  void reset(){
     active = false;
     isActive = false;
     isFinished = false;
  }
}
