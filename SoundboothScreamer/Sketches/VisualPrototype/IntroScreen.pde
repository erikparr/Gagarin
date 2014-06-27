class IntroScreen{
  int timeCount;
  int introTimer;
  Panel panel = new Panel();
  void init(){
    timeCount = second()+30;
    panel.init();
  }

  void update(){
    pushMatrix();
    background(0);
    introTimer = timeCount-second();
    if(introTimer>25){
      translate(width/3,height/3);
      panel.textBox("You get 90 seconds to attempt to break the glass with your voice. \n Try to hit the right pitch by screaming as loud as you can.\n To beat the record, you must break the glass in XX seconds. ",600,400,32,3);
    }
    if(introTimer<25 && introTimer>20){
      translate(panelPos.x/2, height-(height/5));
      pushMatrix();
      translate(-100,-200);
      panel.textBox("Beat the clock",200,100,32,3);
      popMatrix();
      panel.updateStopwatch(millis(), 225,225);
    }
if(introTimer<=20 && introTimer>15){
translate(tWavePos.x,tWavePos.y);
  pushMatrix();
  translate(0,-250);
  panel.textBox("Listen to the sound, you must sing this pitch in order to break the glass!",400,200,32,3);
  popMatrix();
  tWave.update();
}
if(introTimer<=15 && introTimer>10){
translate(tWavePos.x,tWavePos.y);
  pushMatrix();
  translate(0,-250);
  panel.textBox("The pitch of your voice is shown in blue.",400,200,32,3);
  popMatrix();
  tWave.update();
  wave.update();
}
    popMatrix();
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
