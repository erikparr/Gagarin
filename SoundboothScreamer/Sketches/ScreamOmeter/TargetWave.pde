class TargetWave {

  int step =1; // num pixels spaced between each sample drawn
  int yScaler = 100; // scale the height of the waves being drawn
  Oscil osc;
  float[] wavetable;
  float count=0.0;
  boolean inRange = false;
  boolean lockFreq = false;
  int tStamp=0;
  int tCount=0;
  int winTime = 5000;
  PShape line;

  void init(){
    wavetable = new float[width];
    line = createShape();
    line.beginShape();
    line.noFill();
    line.stroke(255);
    for(int i=0; i<wavetable.length; i++){
      line.vertex(i,i,0);
    }
    line.endShape();
    line.setStrokeWeight(5);


  }

  void update(Boolean active){
    pushMatrix();
    pushStyle();
    if(inFreq<targetFreq)
    drawArrowUp();
    if(inFreq>targetFreq)
    drawArrowDown();
    rectMode(CENTER);
    // stroke(255, 235, 22);
    stroke(255);
    updateSinewave();
    updateTimer();
    strokeWeight(2.5);
    // draw the waveforms so we can see what we are monitoring
    for(int i = 0; i < wavetable.length; i++)
    {
      line.setVertex( i,  i, wavetable[i]*yScaler*0.42 );
    }
shape(line,0,0);

    noFill();
    strokeWeight(0.5);
    stroke(EmGrey);
    rect(width/2,0,width,height/7,7);
    if(active){
      fill(EmYellow1);
      noStroke();
      rect(width/2,0,map(tCount, 0, winTime, 0, width),height/7,7);
    }
    popStyle();
    popMatrix();
    stroke(255);

  }

  void updateTimer(){
    if(inFreq > minFreq && inFreq < maxFreq || lockFreq == true){
      if(!inRange)
      tStamp = millis();
      targetCount();
      inRange = true;
      }else{
        inRange = false;
        tCount=0;
      }
    }

void drawArrowUp(){
  pushMatrix();
  translate(width-(width/7),-100);
  stroke(255);
line(0,0,100,-100);
line(100,-100,200,0);
popMatrix();
}

void drawArrowDown(){
  pushMatrix();
  translate(width-(width/7),100);

  stroke(255);
line(0,0,100,100);
line(100,100,200,0);
popMatrix();
}

    void targetCount(){
      tCount = millis()-tStamp;
      if(tCount>=winTime-1000){
        lockFreq=true;
        sendOsc("/killTone", 1);
      }
      if(tCount>=winTime){
      hasWon = true;
      playOutro=true;
      playGame=false;
      tStampOutro=millis();
    }
    }


    void updateSinewave(){
      for(int i = 0; i<wavetable.length-1; i++) {
        wavetable[i]=sin((frameCount*0.1)+i*0.01);
        // wavetable[i] = wavetable[i+1];

      }
      // wavetable[wavetable.length-1]=sin(millis()*10);

    }

    void reset(){
       inRange = false;
       lockFreq = false;
    }
  }
