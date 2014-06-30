class IntroScreen{
  int timeCount;
  int introTimer;
Boolean hlPanel = false;
Boolean hlWatch = false;
Boolean hlWave = false;
  Panel panel = new Panel();
  void init(){
    timeCount = second()+30;
    panel.init();


  }

  void update(){
    pushMatrix();
    background(EmGrey);
    introTimer = timeCount-second();
    panel.updateWindow(panelSize.x, panelSize.y, hlPanel);

    pushMatrix();
    translate(0, height-(height*0.4));
    panel.drawTimerPanel(millis(), hlWatch);
    popMatrix();

    pushMatrix();
    translate(tWavePos.x,tWavePos.y-height*0.39);
    panel.waveWindow(hlWave);
    popMatrix();


    if(introTimer>25){

      translate(width/3,height/3);
      panel.textBox("You get 90 seconds to attempt to break the glass with your voice. Try to hit the right pitch by screaming as loud as you can. To beat the record, you must break the glass in XX seconds. ",600,300,32,3);
    }
    if(introTimer<25 && introTimer>20){
      hlWatch = true;
      pushMatrix();
      translate(panelSize.x/2, height-(height/5));
      translate(-100,-200);
      panel.textBox("Beat the clock",200,100,32,3);
      popMatrix();
    }
    if(introTimer<=20 && introTimer>15){
      hlWatch = false;
      hlWave = true;
      pushMatrix();
      translate(tWavePos.x,tWavePos.y);
      pushMatrix();
      translate(0,-height*0.39);
      panel.waveWindow(hlWave);
      popMatrix();
      tWave.update();
      translate(0,-250);
      panel.textBox("Listen to the sound, you must sing this pitch in order to break the glass! ",400,200,32,3);
      popMatrix();
    }
    if(introTimer<=15 && introTimer>10){

      //draw target wave AND voice wave
      pushMatrix();
      translate(tWavePos.x,tWavePos.y);
      pushMatrix();
      translate(0,-height*0.39);
      panel.waveWindow(hlWave);
      popMatrix();

      tWave.update();
      pushMatrix();
      translate(0,map(tempFreq,0,600,-200,200)); // move wave up or down with frequency
      wave.update();
      popMatrix();
      translate(0,-250);
      panel.textBox("The pitch of your voice is shown in blue. "+mouseX ,400,200,32,3);
      popMatrix();

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
