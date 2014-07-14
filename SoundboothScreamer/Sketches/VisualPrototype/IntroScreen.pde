class IntroScreen{
  // Boolean hlPanel = true;
  // Boolean hlWatch = true;
  // Boolean hlWave = true;
  float frame1;
  float frame2;
  Panel panel = new Panel();

  void init(){
    panel.init();
    frame1 = 0;
    frame2 = startTime-5;
  }

  void update(){
    if(timer>frame1 && timer<frame2){
      panel.textTitles("Welcome to the ScreamOmeter", "Show your energy!");
    }
    if(timer>frame2 && timer<startTime){
      panel.textTitles("Try to beat the high score", currentHiscore+" sec");
      pushMatrix();
      translate(width/2, height- height/4);
      panel.drawTimerPanel(lerp(0,currentHiscore, min(1.0,(millis()*0.001)-frame2)));
      popMatrix();
    }

  }

  // void update(){
  //   pushMatrix();
  //   background(EmGrey);
  //   panel.updateWindow(panelSize.x, panelSize.y, hlPanel);
  //
  //   pushMatrix();
  //   translate(0, height-(height*0.4));
  //   panel.drawTimerPanel(timer, hlWatch);
  //   popMatrix();
  //
  //   pushMatrix();
  //   translate(tWavePos.x,tWavePos.y-height*0.39);
  //   panel.waveWindow(hlWave);
  //   popMatrix();
  //
  //   // pushMatrix();
  //   // updateGradient(panelSize.x,EmRed,EmSilver);
  //   // popMatrix();
  //
  //   if(timer<startTime && timer>startTime-5){
  //
  //     translate(width/3,height/3);
  //     panel.textBox("You get 90 seconds to attempt to break the glass with your voice. Try to hit the right pitch by screaming as loud as you can.",350,400,32,3);
  //   }
  //   if(timer<startTime-5 && timer>startTime-10){
  //     hlWatch = false;
  //     hlPanel = false;
  //     pushMatrix();
  //     translate(15,125);
  //     panel.textBox("To beat the record, you must break the glass in XX seconds.",300,300,32,3);
  //     popMatrix();
  //
  //     pushMatrix();
  //     translate(panelSize.x/2, height-(height/5));
  //     popMatrix();
  //   }
  //   if(timer<=startTime-10 && timer>startTime-15){
  //     hlWatch = true;
  //     hlPanel = true;
  //     hlWave = false;
  //     pushMatrix();
  //     translate(tWavePos.x,tWavePos.y);
  //
  //     pushMatrix();
  //     translate(0,-height*0.39);
  //     panel.waveWindow(hlWave);
  //     popMatrix();
  //     tWave.update(false);
  //     popMatrix();
  //     pushMatrix();
  //     translate(15,125);
  //     panel.textBox("Listen to the sound, you must sing this pitch in order to break the glass! ",400,200,32,3);
  //     popMatrix();
  //   }
  //   if(timer<=startTime-15 && timer>startTime-20){
  //     tWave.setInputFreq(map(sin(millis()*0.001),-1,1,minFreq,maxFreq));
  //
  //     pushMatrix();
  //     translate(15,125);
  //     panel.textBox("The pitch of your voice is shown in blue. " ,400,200,32,3);
  //     popMatrix();
  //
  //     pushMatrix();
  //     translate(tWavePos.x,tWavePos.y);
  //
  //     pushMatrix();
  //     translate(0,-height*0.39);
  //     panel.waveWindow(hlWave);
  //     popMatrix();
  //
  //     tWave.update(false);
  //
  //     pushMatrix();
  //     translate(0,map(tWave.getInputFreq(),minFreq,maxFreq,-200,200)); // move wave up or down with frequency
  //     wave.update();
  //     popMatrix();
  //
  //     popMatrix();
  //
  //   }
  //   if(timer<=startTime-20 && timer>startTime-25){
  //     tWave.setInputFreq(map(sin(millis()*0.001),-1,1,210,290));
  //     pushMatrix();
  //     translate(15,125);
  //     panel.textBox("When you’ve hit the right pitch, you will see the waveforms come together. Hold the pitch to break the glass! " ,400,300,32,3);
  //     popMatrix();
  //
  //     pushMatrix();
  //     translate(tWavePos.x,tWavePos.y);
  //     pushMatrix();
  //     translate(0,-height*0.39);
  //     panel.waveWindow(hlWave);
  //     popMatrix();
  //     tWave.update(true);
  //     translate(0,map(tWave.getInputFreq(),minFreq,maxFreq,-200,200)); // move wave up or down with frequency
  //     wave.update();
  //     popMatrix();
  //   }
  //   if(timer<=startTime-25 && timer>startTime-30){
  //     pushMatrix();
  //     translate(width/3,height/3);
  //     panel.textBox("GET READY!",300,200,62,3);
  //     popMatrix();
  //   }
  //
  //   popMatrix();
  // }
  boolean isActive(){
    if(timer<=startTime){
      return true;
      }else{
        // reset timer and start game
        return false;
      }
    }
    //
    //   // void waveformIntro(){
    //   //
    //   //   tWave.update();
    //   // }
    //   //return intro duration in seconds
  }
