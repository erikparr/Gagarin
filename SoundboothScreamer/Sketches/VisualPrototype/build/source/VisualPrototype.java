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
Panel panel = new Panel();
Waveform wave = new Waveform();
TargetWave tWave = new TargetWave();
LoudnessMonitor loud = new LoudnessMonitor();
public static float tempFreq=0; // replace with real input from osc
public static Minim minim;
public static AudioInput in;
public static float timer;
public static float targetFreq = 250;
int initTime;

public boolean sketchFullScreen() {
  return true;
}

public void setup() {
  size(1440, 1040, P2D);
  font = createFont("GillSans", 48);
  textFont(font);
  textAlign(CENTER, CENTER);
  minim = new Minim(this);
  in = minim.getLineIn();

/* start oscP5, listening for incoming messages at port 47110 */
oscP5 = new OscP5(this,47110);

  loud.init(width/8, height/3, 50, 50);
  panel.init(width/4, height);
  wave.init(width/3, 0);
  tWave.init(width/3, height/2);

  initTime = millis()+60000; //60 seconds
}

public void draw() {

  background(0);
  panel.update();
  wave.update();
  tWave.update();
  loud.update();
  update();

}

public void update(){
  timer = initTime-millis();
  // tempFreq =map(sin(millis()*0.001),-1,1,450,550);
}

public void oscEvent(OscMessage theOscMessage) {
  /* print the address pattern and the typetag of the received OscMessage */
// println(theOscMessage.get(1).floatValue());
tempFreq = theOscMessage.get(1).floatValue();
// waveY =  map(oscFreq, 0, targetFreq*2, height, 0);
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
    in = VisualPrototype.in;
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

    calcLoudness();
    calcAverage();
    translate(px,py);
    textSize(42);
    fill(200);
    text(loudMsg, -wd*3,-ht*3);

    noFill();
    stroke(150);
    amp = in.mix.level();
// fill(color(flashCol, flashCol,flashCol));
fill(65*0.8f,70*0.8f,80*0.8f);

noStroke();
fill(50,150,50,50);
ellipse(0,0,100,100);
fill(150,50,50,50);
ellipse(0,0,200,200);
stroke(0);
    fill(color(map(avg,0.001f,0.03f,50,255), 50,50));
    if(flashCol==255)
    flashCol =50;

    ellipse(0, 0, min(wd+amp*1000,200), min(ht+amp*1000,200));
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
  public void calcLoudness(){

  }

  public void loudnessText(){

    if(avg>0.002f){
      loudMsg = "so very quiet....";
    }
    if(avg>0.01f){
      loudMsg = "not very loud....";
    }
    if(avg>0.02f){
      loudMsg = "pretty loud....";
    }
    if(avg>0.03f){
      loudMsg = "fucking loud!!!";
    }
    if(avg<0.002f){
      loudMsg = "silencio...";

    }

  }
}
class Panel {
  int w,h;

  public void init(int width, int height){
    w= width;
    h= height;
    rectMode(CORNER);
    textAlign(LEFT, CENTER);

  }

  public void update(){

fill(65,70,80);
    noStroke();
rect(0,0,w+51,h);

    textBox();
    fill(200,200,200);
    textSize(96);
    text((int)VisualPrototype.tempFreq, 100, h/2);

    fill(100);
    noStroke();
    rect(w,0,50,h); // sidebar

    setGradient(w,0+150,50,h/2-150,color(100),color(210,20,20));
    setGradient(w,h/2,50,h/2-150,color(210,20,20),color(100));
    stroke(200);
    strokeWeight(1);
    line(w+115,0,w+115,height);
  }

  public void textBox(){
    int px = 0;
    int py = h-h/3;
    int wd = w;
    int ht = 70;
    textSize(52);

    fill(65*0.8f,70*0.8f,80*0.8f);
    noStroke();
    rect(px,py-70,wd,h/3);
    noFill();
    stroke(0);
rect(px,py-70,wd,h/3,7);

    fill(200,200,200);
    text("Countdown: "+ (int)VisualPrototype.this.timer/1000, px,py-(ht/2));
    // text(mouseX +" "+mouseY,20,20);
    // text(sin(millis()*mouseX),20,40);
    stopwatch(wd/2, h-(h/5), 225,225);
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

  public void stopwatch(int px, int py, int wd, int ht){
    float offset = (1.5f*PI);
    fill(50,50,50);
    ellipse(px, py, wd, ht);
    fill(259,20,81);

    arc(px, py, wd, ht, 0+offset, map(VisualPrototype.this.timer, 0, 60000, 0+offset, (2*PI)+offset), PIE);
  }

}
class TargetWave {

  int px, py;
  int step =1; // num pixels spaced between each sample drawn
  int yScaler = 66; // scale the height of the waves being drawn
  Oscil osc;
  float[] wavetable = new float[1024];
  float count=0.0f;
  boolean inRange = false;
  boolean lockFreq = false;
int tStamp=0;
int tCount=0;

  public void init(int x, int y){
    px = x;
    py = y;
    // use the getLineIn method of the Minim object to get an AudioInput    osc.patch(out);
  }

  public void update(){

    // stroke(255, 235, 22);
    stroke(210,20,20);
    updateSinewave();
    updateTimer();
    // draw the waveforms so we can see what we are monitoring
    strokeWeight(2.5f);  // Thicker
    for(int i = 0; i < wavetable.length - 1; i++)
    {
      line( px+i, py+wavetable[i]*yScaler*0.42f, px+i+step, py+wavetable[i]*yScaler*0.42f );
    }

    noFill();
    strokeWeight(0.5f);
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

   Minim minim;
   AudioInput in;
   float px, py;
   int step = 3; // num pixels spaced between each sample drawn
   float bufScaler = 0.666f; // scale the audioBuffer drawn for smaller waveform
   int yScaler = 66; // scale the height of the waves being drawn

   public void init(float x, float y)
   {
     px = x;
     py = y;
     minim = VisualPrototype.minim;
     in = VisualPrototype.in;
   }

   public void update()
   {
     // stroke(0, 255,208);
     py = max(map(tempFreq,0,600,height-height/3,height/3), height/3);
     stroke(21, 166, 223);
     // draw the waveforms so we can see what we are monitoring
     strokeWeight(2.5f);  // Thicker
     for(int i = 0; i < (in.bufferSize()*0.88f) - 1; i++)
     {
       line( px+i, py+in.left.get(i)*yScaler, px+i+step, py+in.left.get(i+step)*yScaler );
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
