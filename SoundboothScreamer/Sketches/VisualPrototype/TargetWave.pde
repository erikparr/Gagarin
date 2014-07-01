class TargetWave {

  int step =1; // num pixels spaced between each sample drawn
  int yScaler = 66; // scale the height of the waves being drawn
  Oscil osc;
  float[] wavetable = new float[900];
  float count=0.0;
  boolean inRange = false;
  boolean lockFreq = false;
int tStamp=0;
int tCount=0;


  void update(Boolean active){
pushMatrix();

    // stroke(255, 235, 22);
    stroke(EmRed);
    updateSinewave();
    updateTimer();
    // draw the waveforms so we can see what we are monitoring
    strokeWeight(2.5);  // Thicker
    for(int i = 0; i < wavetable.length - 1; i++)
    {
      line( i, wavetable[i]*yScaler*0.42, i+step, wavetable[i]*yScaler*0.42 );
    }

    noFill();
    strokeWeight(0.5);
    stroke(EmGrey);
    rect(0,-yScaler*0.85,width*0.66,height/7,7);
    if(active){
    fill(EmYellow1);
    noStroke();
    rect(0,-yScaler*0.85,map(tCount, 0, 5000, 0, width*0.66),height/7,7);
  }
    popMatrix();
  }

  void updateTimer(){
    if((inFreq > (targetFreq)-50) && (inFreq < (targetFreq)+50) || lockFreq == true){
      if(!inRange)
      tStamp = millis();
      targetCount();
      inRange = true;
      }else{
        inRange = false;
        tCount=0;
      }

    }

void setInputFreq(float input){
inFreq = input;
}

    void targetCount(){
      tCount = millis()-tStamp;
}

  float getInputFreq(){
    return inFreq;
  }
    void updateSinewave(){
      for(int i = 0; i<wavetable.length-1; i++) {
        wavetable[i]=sin(count+i*0.067);
        count=count+0.001;
        // wavetable[i] = wavetable[i+1];
        // println(wavetable[i]);

      }
      // wavetable[wavetable.length-1]=sin(millis()*10);

    }
  }
