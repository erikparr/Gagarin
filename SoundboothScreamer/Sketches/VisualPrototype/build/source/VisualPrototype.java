import processing.core.*; 
import processing.data.*; 
import processing.event.*; 
import processing.opengl.*; 

import ddf.minim.*; 
import ddf.minim.ugens.*; 
import oscP5.*; 
import netP5.*; 

import java.util.HashMap; 
import java.util.ArrayList; 
import java.io.File; 
import java.io.BufferedReader; 
import java.io.PrintWriter; 
import java.io.InputStream; 
import java.io.OutputStream; 
import java.io.IOException; 

public class VisualPrototype extends PApplet {

/*Todo:
integrate with osc input from SC app:
-
*/
 // audio library -- used for audio visualization only




OscP5 oscP5;
PFont font;
IntroScreen intro = new IntroScreen();
OutroScreen outro = new OutroScreen();
public Panel panel = new Panel();
public Waveform wave = new Waveform();
public TargetWave tWave = new TargetWave();
// public LoudnessMonitor loud = new LoudnessMonitor();
public  float tempFreq=100; // replace with real input from osc
public  Minim minim;
public  AudioInput in;
public  float timer;
public  float targetFreq = 250;
public int EmRed =  color(254,0,12);
public int EmBlue =  color(12,71,157);
public int EmBlue1 =  color(12,71,157,168);
public int EmGrey =  color(90,90,90);
public int EmSilver =  color(181,181,181);
public int EmSilver1 =  color(181,181,181,168);
public int EmYellow =  color(255,215,0);
public int EmBurgundy =  color(166,25,46);
public int EmRuby =  color(215,56,114);
public int EmAmber =  color(242,172,51);
public int EmVermilion =  color(240,88,34);
public int EmIndigo =  color(0,47,108);
public int EmGrad1 =  color(232,29,48);
public int EmGrad2 =  color(0,102,175);
public PVector wavePos;
public PVector tWavePos;
public PVector panelPos;
int initTime;
public boolean sketchFullScreen() {
  return true;
}

public void setup() {
  size(1440, 1040, P2D);
  font = createFont("GillSans", 48);
intro.init();
outro.init();
  textFont(font);
  textAlign(CENTER, CENTER);
  minim = new Minim(this);
  in = minim.getLineIn();

  /* start oscP5, listening for incoming messages at port 47110 */
  oscP5 = new OscP5(this,47110);

 wavePos = new PVector(width/3, 0);
 tWavePos = new PVector(width/3, height/2);
 panelPos = new PVector(width/4, height);

  // loud.init(width/8, height/3, 50, 50);
  panel.init();

  initTime = millis()+60000; //60 seconds
}

public void draw() {

  background(0);

  if(intro.isActive()){
  intro.update();
}else{
  timer = initTime-millis();
  panel.updateStopwatch(timer, 225,225);
  wave.update();
  tWave.update();
  // loud.update();
}
  if(timer<0)
  outro.update();

tempFreq = map(sin(millis()*0.001f),-1,1,0,600);
}

public void oscEvent(OscMessage theOscMessage) {
  /* print the address pattern and the typetag of the received OscMessage */
  // println(theOscMessage.get(1).floatValue());
  tempFreq = theOscMessage.get(1).floatValue();
  // waveY =  map(oscFreq, 0, targetFreq*2, height, 0);
}
class IntroScreen{
  int timeCount;
  int introTimer;
  Panel panel = new Panel();
  public void init(){
    timeCount = second()+30;
    panel.init();
  }

  public void update(){
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

  public boolean isActive(){
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
  public int getIntroDuration(){
    return introTimer;
  }
}
class LoudnessMonitor {

  AudioInput in;
  float amp;
  float avg;
  float flashFreq =0;
  String loudMsg="";
  int wd, ht, px, py;
  float[] avgAmp = new float[128]; // store the last 1024 amplitude values in an array, to get average
  float flashCol;

  public void init(int x, int y, int width, int height){
    wd = width;
    ht = height;
    px = x;
    py = y;
  }

  public void update(){
    pushMatrix();
    // stroke(0);
    // fill(65*0.6,70*0.6,80*0.6);
    // rect(0,0,mouseX,mouseY,7);

    calcAverage();
    translate(px,py);
    textSize(42);
    fill(200);
    text(loudMsg, -wd*3,-ht*3);

    noFill();
    stroke(150);
    amp = in.mix.level();
    noStroke();

    drawGradient(0,0,(int)min(wd+amp*1000,200),EmGrad1,EmGrad2);
    // fill(color(map(avg,0.001,0.03,50,255), 50,50));
    // if(flashCol==255)
    // flashCol =50;

    // ellipse(0, 0, min(wd+amp*1000,200), min(ht+amp*1000,200));
    stroke(0);
    loudnessText();

    popMatrix();
  }

  public void calcAverage(){
    float sum=0;
    avgAmp[avgAmp.length-1] = amp;

    for(int i = 0; i<avgAmp.length-1; i++) {
      avgAmp[i] = avgAmp[i+1];
      sum = (sum+avgAmp[i]);
    }

    avg = sum/avgAmp.length;
    flashFreq = flashFreq+ avg;
    if(flashFreq>0.1f){
      flashCol = 255;
      flashFreq=0;
    }

  }

  public void drawGradient(float x, float y, int rad, int c1, int c2) {
    float maxRad = 200;
    float r1 = red(c1);
    float g1 = green(c1);
    float b1 = blue(c1);
    float r2 = red(c2);
    float g2 = green(c2);
    float b2 = blue(c2);
    println(r1+" "+g1+" "+b1);
    println(r2+" "+g2+" "+b2);
    println("-");

    for (int r = rad; r > 0; --r) {
      println(map(r,maxRad,0,r1,r2)+" "+map(r,maxRad,0,g1,g2)+" "+map(r,maxRad,0,b1,b2));

      fill(map(r,maxRad,0,r1,r2), map(r,maxRad,0,g1,g2), map(r,maxRad,0,b1,b2));
      ellipse(x, y, r, r);
    }
  }

  public void loudnessText(){

    if(avg>0.002f){
      loudMsg = "Very Quiet...";
    }
    if(avg>0.01f){
      loudMsg = "Sing louder ...";
    }
    if(avg>0.02f){
      loudMsg = "Keep going!";
    }
    if(avg>0.03f){
      loudMsg = "That's LOUD!!!";
    }
    if(avg<0.002f){
      loudMsg = "Start singing...";

    }

  }
}
class OutroScreen{
XML xml;

public void init(){

}

public void update(){
  background(200);
  textSize(96);
  text("HIGH SCORE??", width/2, height/2);

}

}
class Panel {

  public void init(){
    rectMode(CORNER);
    textAlign(LEFT, CENTER);
  }

  public void updateWindow(float width, float height){
    int w= (int)width;
    int h= (int)height;
    noFill();
    stroke(EmSilver);
    rect(0,0,w+51,h,7);

  }

  public void updateSidebar(float width, float height){
    int w= (int)width;
    int h= (int)height;
    fill(EmSilver);
    noStroke();
    rect(w+15,0,100,h); // sidebar

  }

  public void updateGradient(float width, float height, int color1, int color2){
    int w= (int)width;
    int h= (int)height;
    setGradient(w+15,0+150,100,h/2-150,color1,color2);
    setGradient(w+15,h/2,100,h/2-150,color2,color1);
    // setGradient(w+15,0+150,100,h/2-150,EmSilver,EmRed);
    // setGradient(w+15,h/2,100,h/2-150,EmRed,EmSilver);

  }

  // void update(){
  //   updateStopwatch(w/2, h-(h/5), 225,225);
  // }

  public void textBox(String text, int w, int h, int textSize, int numLines){
    int offset = 40;
    int wd = 3;
    textSize(textSize);
    stroke(EmBlue);
    strokeWeight(3);
    noFill();
    rect(-offset/2,-offset/2,w+offset,h,7);
    fill(EmGrey);
    noStroke();
    rect(-offset/2+(wd/2),-offset/2+(wd/2),w+offset-wd,h-wd,7);

fill(255);
    text(text,0,0,w,h);
    // text(mouseX +" "+mouseY,20,20);
    // text(sin(millis()*mouseX),20,40);
  }

  // void freqChart(int px, int py){
  // rect(px,py,wd,ht);
  //
  // }
  public void setGradient(int x, int y, float w, float h, int c1, int c2 ) {

    noFill();

    for (int i = y; i <= y+h; i++) {
      float inter = map(i, y, y+h, 0, 1);
      int c = lerpColor(c1, c2, inter);
      stroke(c);
      strokeWeight(1);
      line(x, i, x+w, i);
      if(i%(height/20)==0){
        if(i%(height/5)==0)
        strokeWeight(2.0f);
        else if(i%(height/10)==0)
        strokeWeight(1.0f);
        else
        strokeWeight(0.5f);
        stroke(0);
        line(x+(w/2), i, x+w, i);
      }
      if(i==height/2){
        strokeWeight(10.0f);
        stroke(0);
        line(x+(w/2), i, x+w, i);
      }
    }

  }

  public void updateStopwatch(float timescale, int w, int h){
    float offset = (1.5f*PI);
    fill(50,50,50);
    ellipse(0, 0, w, h);
    fill(EmBlue);
    arc(0, 0, w, h, 0+offset, map(timescale, 0, 60000, 0+offset, (2*PI)+offset), PIE);
  }

}
class TargetWave {

  int step =1; // num pixels spaced between each sample drawn
  int yScaler = 66; // scale the height of the waves being drawn
  Oscil osc;
  float[] wavetable = new float[1024];
  float count=0.0f;
  boolean inRange = false;
  boolean lockFreq = false;
int tStamp=0;
int tCount=0;


  public void update(){

    // stroke(255, 235, 22);
    stroke(EmRed);
    updateSinewave();
    updateTimer();
    // draw the waveforms so we can see what we are monitoring
    strokeWeight(2.5f);  // Thicker
    for(int i = 0; i < wavetable.length - 1; i++)
    {
      line( i, wavetable[i]*yScaler*0.42f, i+step, wavetable[i]*yScaler*0.42f );
    }

    noFill();
    strokeWeight(0.5f);
    stroke(180);
    rect(0,-65,width-width/3,height/7,7);
    fill(EmSilver);
    stroke(0,0,0,0);
    rect(0,-65,map(tCount,0,5000,0,width-width/3),height/7,7);
  }

  public void updateTimer(){
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

    public void targetCount(){
      tCount = millis()-tStamp;
}

    public void updateSinewave(){
      for(int i = 0; i<wavetable.length-1; i++) {
        wavetable[i]=sin(count+i*0.067f);
        count=count+0.001f;
        // wavetable[i] = wavetable[i+1];
        // println(wavetable[i]);

      }
      // wavetable[wavetable.length-1]=sin(millis()*10);

    }
  }
 class Waveform {

   float  py;
   int step = 3; // num pixels spaced between each sample drawn
   float bufScaler = 0.666f; // scale the audioBuffer drawn for smaller waveform
   int yScaler = 66; // scale the height of the waves being drawn


   public void update()
   {
     // stroke(0, 255,208);
     py = max(map(tempFreq,0,600,height-height/3,0), height/3);
     stroke(EmBlue);
     // draw the waveforms so we can see what we are monitoring
     strokeWeight(2.5f);  // Thicker
     for(int i = 0; i < (in.bufferSize()*0.88f) - 1; i++)
     {
       line( i, py+in.left.get(i)*yScaler, i+step, py+in.left.get(i+step)*yScaler );
     }

   }

 }
  static public void main(String[] passedArgs) {
    String[] appletArgs = new String[] { "VisualPrototype" };
    if (passedArgs != null) {
      PApplet.main(concat(appletArgs, passedArgs));
    } else {
      PApplet.main(appletArgs);
    }
  }
}
