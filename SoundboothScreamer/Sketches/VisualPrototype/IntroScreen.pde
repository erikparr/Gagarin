class IntroScreen{
  int timeCount;
  int introTimer;
Panel panel = new Panel();
  void init(){
    timeCount = second()+20;
  }

  void update(){
    background(0);
    introTimer = timeCount-second();
    if(introTimer>15){
      textSize(96);
      text("Instructions: ", width/2,height/2);
    }
    if(introTimer<15){
      tWave.update();
      textSize(64);
      stroke(EmSilver);
      text("Listen to the target frequency -- you must match the pitch to break the glass!", mouseX, mouseY);
    }
    if(introTimer<10 && introTimer>5){
      wave.update();
    }

  }

  boolean isActive(){
    if(introTimer>=0)
    return true;
    else
    return false;
  }

  // void waveformIntro(){
  //
  //   tWave.update();
  // }
  //return intro duration in seconds
  int getIntroDuration(){
    return introTimer;
  }
}
