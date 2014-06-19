class TargetWave {

  int px, py;
  int step =1; // num pixels spaced between each sample drawn
  int yScaler = 66; // scale the height of the waves being drawn
  Oscil osc;
  float[] wavetable = new float[1024];
  float count=0.0;
  boolean inRange = false;
  boolean lockFreq = false;
int tStamp=0;
int tCount=0;

  void init(int x, int y){
    px = x;
    py = y;
    // use the getLineIn method of the Minim object to get an AudioInput    osc.patch(out);
  }

  void update(){

    // stroke(255, 235, 22);
    stroke(210,20,20);
    updateSinewave();
    updateTimer();
    // draw the waveforms so we can see what we are monitoring
    strokeWeight(2.5);  // Thicker
    for(int i = 0; i < wavetable.length - 1; i++)
    {
      line( px+i, py+wavetable[i]*yScaler*0.42, px+i+step, py+wavetable[i]*yScaler*0.42 );
    }

    noFill();
    strokeWeight(0.5);
    stroke(180);
    rect(px,py-65,width-width/3,height/7,7);
    fill(255,249,86,100);
    stroke(0,0,0,0);
    rect(px,py-65,map(tCount,0,5000,0,width-width/3),height/7,7);


    // for( int i = 0; i < out.bufferSize() - 1; i++ )
    //     {
    //       line( px+i, py+out.left.get(i)*yScaler, px+i+step, py+out.left.get(i+1)*yScaler );
    //     }

  }

  void updateTimer(){
    if((tempFreq > (targetFreq)-50) && (tempFreq < (targetFreq)+50) || lockFreq == true){
      if(!inRange)
      tStamp = millis();
      targetCount();
      inRange = true;
      }else{
        inRange = false;
        tCount=0;
      }

    }

    void targetCount(){
      tCount = millis()-tStamp;
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
