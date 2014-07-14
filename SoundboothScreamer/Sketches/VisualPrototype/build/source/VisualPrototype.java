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
Highscore hiscore = new Highscore();
public Panel panel = new Panel();
public Waveform wave = new Waveform();
public TargetWave tWave = new TargetWave();
// public LoudnessMonitor loud = new LoudnessMonitor();
public  Minim minim;
public  AudioInput in;
public  float timer;
public  float targetFreq = 250;
public int EmRed =  color(254,0,12);
public int EmBlue =  color(12,71,157);
public int EmBlueGrad =  color(6,117,190);
public int EmCyan =  color(0,163,224);
public int EmBlue1 =  color(12,71,157,168);
public int EmLiteBlue =  color(196,222,243);
public int EmGrey =  color(90,90,90);
public int EmSea =  color(0,112,150);
public int EmSilver =  color(181,181,181);
public int EmSilver1 =  color(181,181,181,168);
public int EmYellow =  color(255,215,0);
public int EmYellow1 =  color(255,215,0,100);
public int EmBurgundy =  color(166,25,46);
public int EmRuby =  color(215,56,114);
public int EmAmber =  color(242,172,51);
public int EmVermilion =  color(240,88,34);
public int EmIndigo =  color(0,47,108);
public int EmGrad1 =  color(232,29,48);
public int EmGrad2 =  color(0,102,175);
public PVector tWavePos;
public PVector panelSize;
public float minFreq;
public float maxFreq;
public float startTime;
public int currentHiscore;
float inFreq; // replace with real input from osc
int initTime;

public boolean sketchFullScreen() {
  return true;
}

public void setup() {
  size(1366, 768, P2D); // 1600 x 900
  // font = createFont("GillSans", 48);
  font = createFont("EMprintW01-Regular", 120);
  startTime = 10;
  initTime =  (int)(millis()*0.001f)+(int)startTime; //90 seconds
  minim = new Minim(this);
  in = minim.getLineIn();
  intro.init();
  outro.init();
  tWave.init();
  wave.init();
  textFont(font);
  textAlign(CENTER, CENTER);

  /* start oscP5, listening for incoming messages at port 47110 */
  oscP5 = new OscP5(this,47110);

  tWavePos = new PVector(width/3, height/2);
  panelSize = new PVector(width*0.286f, height);

  minFreq = targetFreq-50; //set min and max freq to target frequency from SC
  maxFreq = targetFreq+50;
  // loud.init(width/8, height/3, 50, 50);
  panel.init();
  hiscore.init(day(),month());
}

public void draw() {

  setGradient(0, 0, width, height, EmBlue, EmCyan, 1);
  // background(EmBlue);
inFreq = map(sin(millis()*0.001f),-1,1,targetFreq-100,targetFreq+100);

  timer = (millis()*0.001f);

  if(intro.isActive()){
    intro.update();
    }else{
      tWave.setInputFreq(inFreq);
      panel.wavePanel();
    }
    // if(timer<0)
    // outro.update();
// text(frameRate,100,100);
text(frameRate,100,100);

  }


public void setGradient(int x, int y, float w, float h, int c1, int c2, int axis ) {

  noFill();

    for (int i = x; i <= x+w; i++) {
      float inter = map(i, x, x+w, 0, 1);
      int c = lerpColor(c1, c2, inter);
      stroke(c);
      line(i, y, i, y+h);
    }
}


  public void oscEvent(OscMessage theOscMessage) {
    /* print the address pattern and the typetag of the received OscMessage */
    // println(theOscMessage.get(1).floatValue());
    inFreq = theOscMessage.get(1).floatValue();
    // waveY =  map(oscFreq, 0, targetFreq*2, height, 0);
  }
JSONObject highscore;
Boolean hasHighscore=false;
int defaultHighscore = 60;

class Highscore{

  public void init(int day, int month) {
    highscore = loadJSONObject("highscore.json");
    String dateString = day+"-"+month;
    String date = highscore.getString("date");
    // if we're on a new day, reset the highscore to the default
    if(date.equals(dateString) == false){
    highscore.setInt("score", defaultHighscore);
    highscore.setString("date", dateString);
    saveJSONObject(highscore, "data/highscore.json");
}
  currentHiscore = highscore.getInt("score"); // set current highscore from json file

  }

  public void saveHighscore(int pScore){ //(int pScore, String pName, String pPhone)
    // determine score ranking
        int score = highscore.getInt("score");
        // String name = highscore.getString("name");
        // String phone = highscore.getString("phone");

        if(pScore>score){
          hasHighscore = true; // if we reached a high score, we record the info and break out from loop
          highscore.setInt("score", pScore);
          // highscore.setString("name", pName);
          // highscore.setString("phone", pPhone);
          print("HIGHSCORE!!  "+ pScore);
          }else{
            println( " :( ");
          }
      saveJSONObject(highscore, "data/highscore.json");
    }
  }
class IntroScreen{
  // Boolean hlPanel = true;
  // Boolean hlWatch = true;
  // Boolean hlWave = true;
  float frame1;
  float frame2;
  Panel panel = new Panel();

  public void init(){
    panel.init();
    frame1 = 0;
    frame2 = startTime-5;
  }

  public void update(){
    if(timer>frame1 && timer<frame2){
      panel.textTitles("Welcome to the ScreamOmeter", "Show your energy!");
    }
    if(timer>frame2 && timer<startTime){
      panel.textTitles("Try to beat the high score", currentHiscore+" sec");
      pushMatrix();
      translate(width/2, height- height/4);
      panel.drawTimerPanel(lerp(0,currentHiscore, min(1.0f,(millis()*0.001f)-frame2)));
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
  //     panel.textBox("When you\u2019ve hit the right pitch, you will see the waveforms come together. Hold the pitch to break the glass! " ,400,300,32,3);
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
  public boolean isActive(){
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
  PImage logo;
  PImage logoMsk;
  // CamGrab camera = new CamGrab();

  public void init(){
    rectMode(CORNER);
    textAlign(LEFT, CENTER);
    // camera.init();
    logo = loadImage("logoSm.jpg");  // Load an image into the program
    logoMsk = loadImage("logoSmMsk3.jpg");  // Load an image into the program
    logo.mask(logoMsk);
  }

  public void updateWindow(float width, float height, Boolean highlight){
    int w= (int)width;
    int h= (int)height;
    noStroke();
    fill(EmSilver);
    rect(0,0,w,h);
    textSize(46);
    fill(EmRed);
    text("HIGHSCORE: 1:52",width/20,height/10);
    // image(logo,-20,-20);
    // camera.update();
    if(highlight){
      fill(0,0,0,150);
      rect(0,0,w,h);
    }
  }

  public void textTitles(String subTitle, String title){
    pushStyle();
    textAlign(CENTER);
    fill(205);
    textSize(64);
    text(subTitle, width/2, height/2 - (height/5));
    textSize(136);
    text(title, width/2, height/2);
    popStyle();
  }

  public void textByline(String text){

  }


  public void updateSidebar(float width, float height){
    int w= (int)width;
    int h= (int)height;
    fill(EmSilver);
    noStroke();
    rect(w+15,0,100,h); // sidebar

  }


  public void wavePanel(){
    pushStyle();
    strokeWeight(2.5f);  // Thicker
    pushMatrix();
    translate(0, height/2);
    tWave.update(true);
    pushMatrix();
    translate(0,map(inFreq,targetFreq-100,targetFreq+100,-100,100));
    wave.update();
    popMatrix();
    popMatrix();
    fill(EmSilver);
    textSize(42);
    text(" Time left:", width/12, (height)-(height/4));
    textSize(136);
    text((int)timer, width/12, (height)-(height/4)+(height/10));
    textSize(92);
    text(" sec", width/5.5f, (height)-(height/4)+(height/8));
    image(logo,width -(width/4), (height)-(height/4)+(height/10));
    popStyle();
  }

  public void waveWindow(Boolean highlight){
    stroke(EmSilver);
    // noFill();
    // strokeWeight(3);
    // rect(0,0,width*0.658,height*0.78);
    fill(0);
    noStroke();
    rect(0,0,width*0.658f,height*0.78f);
    if(highlight){
      fill(0,155);
      rect(0,0,width*0.658f,height*0.78f);
    }
  }

  public void textBox(String text, int w, int h, int textSize, int numLines){
    int offset = 40;
    int wd = 3;
    textSize(textSize);
    // stroke(EmBlue);
    // strokeWeight(3);
    // noFill();
    // rect(-offset/2,-offset/2,w+offset,h,7);
    pushMatrix();

    pushMatrix();
    translate(w/45,w/45);
    fill(EmSilver);
    noStroke();
    rect(-offset/2+(wd/2),(wd/2),w+offset-wd,h-wd+15);
    popMatrix();
    fill(EmBlue);
    noStroke();
    rect(-offset/2+(wd/2),(wd/2),w+offset-wd,h-wd+15);

    fill(255);
    text(text,0,0,w,h);
    // text(mouseX +" "+mouseY,20,20);
    // text(sin(millis()*mouseX),20,40);
    popMatrix();
  }

  // void freqChart(int px, int py){
  // rect(px,py,wd,ht);
  //
  // }

  public void drawTimerPanel(float currentTime){
    pushStyle();
    noStroke();
    float offset = (1.5f*PI);
    fill(EmLiteBlue);
    ellipse(0,0,225,225);
    fill(255);
    arc(0,0, 225, 225, 0+offset, map(currentTime, 90, 0,(2*PI)+offset, 0+offset), PIE);
    fill(EmBlueGrad);
    ellipse(0,0,100,100);
    popStyle();
  }
}
class TargetWave {

  int step =1; // num pixels spaced between each sample drawn
  int yScaler = 100; // scale the height of the waves being drawn
  Oscil osc;
  float[] wavetable;
  float count=0.0f;
  boolean inRange = false;
  boolean lockFreq = false;
  int tStamp=0;
  int tCount=0;
  PShape line;

  public void init(){
    wavetable = new float[width];
    line = createShape();
    line.beginShape();
    line.noFill();
    line.stroke(255);
    for(int i=0; i<wavetable.length; i++){
      line.vertex(i,i,0);
    }
    line.endShape();

  }

  public void update(Boolean active){
    pushMatrix();
    pushStyle();
    rectMode(CENTER);
    // stroke(255, 235, 22);
    stroke(255);
    updateSinewave();
    updateTimer();
    strokeWeight(2.5f);
    // draw the waveforms so we can see what we are monitoring
    for(int i = 0; i < wavetable.length; i++)
    {
      line.setVertex( i,  i, wavetable[i]*yScaler*0.42f );
    }
shape(line,0,0);

    noFill();
    strokeWeight(0.5f);
    stroke(EmGrey);
    rect(width/2,0,width,height/7,7);
    if(active){
      fill(EmYellow1);
      noStroke();
      rect(width/2,0,map(tCount, 0, 5000, 0, width),height/7,7);
    }
    popStyle();
    popMatrix();
  }

  public void updateTimer(){
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

    public void setInputFreq(float input){
      inFreq = input;
    }

    public void targetCount(){
      tCount = millis()-tStamp;
    }

    public float getInputFreq(){
      return inFreq;
    }

    public void updateSinewave(){
      for(int i = 0; i<wavetable.length-1; i++) {
        wavetable[i]=sin(count+i*0.01f);
        count=count+0.00025f;
        // wavetable[i] = wavetable[i+1];
        // println(wavetable[i]);

      }
      // wavetable[wavetable.length-1]=sin(millis()*10);

    }
  }
 class Waveform {

   float  py;
   int yScaler = 100; // scale the height of the waves being drawn
   float step = 10;
   PShape line;

   public void init(){
     line = createShape();
     line.beginShape();
     line.noFill();
     line.stroke(EmYellow);
     for(int i=0; i<in.bufferSize()*0.15f; i++){
       line.vertex(i,i,0);
     }
    //  println(line.getVertexCount());
     line.endShape();
   }

   public void update()
   {
     noFill();
     // stroke(0, 255,208);
     strokeWeight(2.5f);
     // draw the waveforms so we can see what we are monitoring
     for(int i = 0; i < line.getVertexCount(); i++){
// line((i*step), in.left.get(i)*yScaler, (i*step)+(step/2), py+in.left.get(i+1)*yScaler );
    line.setVertex(i, (i*step), in.left.get(i)*yScaler);
     }
shape(line,0,0);
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
