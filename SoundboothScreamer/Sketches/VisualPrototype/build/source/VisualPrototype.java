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
- difficulty w/ targetThresh
*/
 // audio library -- used for audio visualization only




OscP5 oscP5;
NetAddress myRemoteLocation;
int b1Val;
int b2Val;
int b3Val;
PFont font;
AudioPlayer player;
IntroScreen intro = new IntroScreen();
OutroScreen outro = new OutroScreen();
Highscore hiscore = new Highscore();
public Panel panel = new Panel();
public Waveform wave = new Waveform();
public TargetWave tWave = new TargetWave();
// public LoudnessMonitor loud = new LoudnessMonitor();
public  Minim minim;
public  AudioInput in;
public  float targetFreq = 0;
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
public int currentHiscore;
public float playTimer;
public float tStampPlay;
public float outroTimer;
public float tStampOutro;
public float inFreq; // input frequency from Supercollider
float freqVal; // mapped inFreq value to screen height range
String typetag;
float targetThresh = 50;
Boolean hasWon =false; //set to true when game has been won
Boolean breakGlass =true; //set to true to send osc msg to SC to break glass on win
public Boolean startSound ;
public Boolean playIntro;
public Boolean playGame;
public Boolean playOutro;
float gameDuration = 5;

public boolean sketchFullScreen() {
  return true;
}

public void setup() {
  size(1920,1080, P2D); // 1600 x 900
  noCursor();
  // font = createFont("GillSans", 48);
  font = createFont("EMprintW01-Regular", 115);
  minim = new Minim(this);
  in = minim.getLineIn();
  player = minim.loadFile("applause.aiff");
  textFont(font);
  textAlign(CENTER, CENTER);
  /*------------init classes ------------*/
  intro.init();
  outro.init();
  tWave.init();
  wave.init();
  /*------------OSC ------------*/
  oscP5 = new OscP5(this,47110);
  myRemoteLocation = new NetAddress("127.0.0.1",57120);
  b1Val = 1;
  b2Val = 1;
  b3Val = 1;
  /*------------other vars --------------------*/
  tWavePos = new PVector(width/3, height/2);
  panelSize = new PVector(width*0.286f, height);
  // loud.init(width/8, height/3, 50, 50);
  panel.init();
  hiscore.init(day(),month());
  resetGame();
}

public void draw() {
  setGradient(0, 0, width, height, EmBlue, EmCyan, 1);
  // background(EmBlue);

  if(playIntro){
    intro.update();
    }else if(playGame){
      panel.wavePanel();
      playTimer = (millis()-tStampPlay)*0.001f;
      }else if(playOutro){
        outro();
        }else{
          text("Press Start", width/3,height/2);
        }

        if(startSound)
        oscStart();
        if(playTimer>=gameDuration && playGame){
          //player has ran out of time, gameover
          playOutro=true;
          playGame=false;
          tStampOutro=millis();
        }
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
        if(theOscMessage.checkAddrPattern("/target")==true) {
          //get target frequency of glass from SC
          targetFreq = theOscMessage.get(0).floatValue();
          minFreq = targetFreq-targetThresh; //set min and max freq to target frequency from SC
          maxFreq = targetFreq+targetThresh;
        }
        if(theOscMessage.checkAddrPattern("/pitch")==true && targetFreq>0) {
          // typetag = theOscMessage.typetag();
          // inFreq = theOscMessage.get(0).floatValue(); //
          inFreq = targetFreq; //
        }
      }

      public void sendOsc(String adrs, int val){
        OscMessage myMessage = new OscMessage(adrs);
        myMessage.add(val); /* add an int to the osc message */
        oscP5.send(myMessage, myRemoteLocation);
      }

      public void oscStart(){
        sendOsc("/oscGameStart", b2Val);
        startSound = false;
      }

      public void resetGame(){
        println("resetting");
        playIntro = false;
        playGame = false;
        playOutro = false;
        breakGlass = true; //set to true to send osc msg to SC to break glass on win
        startSound = false; // send osc msg to SC on game start
        hasWon =false; //set to true when game has been won
        intro.reset();
        hiscore.reset();
        panel.reset();
      }

      public void outro(){
        if(hasWon){
          if(hiscore.saveHighscore((int)playTimer) || hiscore.hasHighscore()){
            text(hiscore.getCurrentHiscore() +" seconds!", width/3,height/3);
            text("New high score!",width/3,height/3+200);
            player.play();
            }else{
              text("You Win!", width/3,height/3);
            }
            if(breakGlass){
              sendOsc("/killTone", 1);
              breakGlass=false;
            }
            }else{
              text("Sorry, you lose.", width/3,height/3);
            }
            println(outroTimer);
            if(outroTimer>=5){
              resetGame();
            }
            outroTimer = (millis()-tStampOutro)*0.001f;
          }

          //buttons in booth work like simulated keyboards
          public void keyPressed() {

            if (key == TAB) {
              println("tab");
              sendOsc("/1/toggle1", b1Val);
              if(b1Val==0)
              b1Val=1;
              else
              b1Val=0;
            }
            if (key == 'q') {
              sendOsc("/oscRefTone", 1);
            }
            if (key == '5') {
              playIntro = true;
            }
          }
JSONObject highscore;
int defaultHighscore = 60;
Boolean hasHighscore=false;
class Highscore{

  public void init(int day, int month) {
    hasWon=false;
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

  public Boolean saveHighscore(int pScore){ //(int pScore, String pName, String pPhone)
     hasHighscore=false;
// determine score ranking
    int score = highscore.getInt("score");
println("score: "+score+" player score: "+pScore);
    // String name = highscore.getString("name");
    // String phone = highscore.getString("phone");

    if(pScore<score){
      println("new high score");
      hasHighscore = true; // if we reached a high score, we record the info and break out from loop
      highscore.setInt("score", pScore);
      }
      saveJSONObject(highscore, "data/highscore.json");
      return hasHighscore;
    }

  public int getCurrentHiscore(){
    return currentHiscore;
  }

  public Boolean hasHighscore(){
    return hasHighscore;
  }

  public void reset(){
    hasHighscore=false;
  };
  }
class IntroScreen{
  float frame1;
  float frame2;
  Panel panel = new Panel();
  float timer;
  int tStamp = 0;
  Boolean isActive = false;
  float startTime;

  public void init(){
    panel.init();
    frame1 = 0;
    frame2 = 5;
  startTime = 10;
  }

  public void update(){
    //do once
    if(!isActive){
      tStamp = millis();
      isActive=true;
      println("setIntroTimeStamp");

    }

    timer = ((millis()-tStamp)*0.001f);
    if(timer>frame1 && timer<frame2){
      panel.textTitles("Welcome to the ScreamOmeter", "Show your energy!");
    }
    if(timer>frame2 && timer<startTime){
      panel.textTitles("Try to beat the high score", currentHiscore+" sec");
      pushMatrix();
      translate(width/2, height- height/4);
      panel.drawTimerPanel(lerp(0,currentHiscore, min(1.0f,(timer)-frame2)));
      popMatrix();
    }

if(timer>startTime){
  startSound = true;
  playGame = true;
  playIntro = false;
  println("start game");
}

  }

  public void reset(){
    isActive = false;
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
  PImage logo;
  PImage logoMsk;
  Boolean isActive;
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
    //set timestamp once per game
    if(!isActive){
      tStampPlay = millis();
      isActive=true;
      println("setPlayTimeStamp");
    }

    pushStyle();
    strokeWeight(2.5f);  // Thicker
    pushMatrix();
    translate(0, height/2);
    tWave.update(true);
    pushMatrix();
    translate(0,freqVal);
    wave.update();
    popMatrix();
    popMatrix();
    fill(EmSilver);
    textSize(42);
    text(" Time:", width/12, (height)-(height/4));
    textSize(136);
    text((int)playTimer, width/12, (height)-(height/4)+(height/10));
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

  public void reset(){
    isActive = false;
    tWave.reset();
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
  int winTime = 5000;
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
      rect(width/2,0,map(tCount, 0, winTime, 0, width),height/7,7);
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


    public void targetCount(){
      tCount = millis()-tStamp;
      if(tCount>=winTime)
      hasWon = true;
      tStampOutro=millis();
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

    public void reset(){
       inRange = false;
       lockFreq = false;
    }
  }
 class Waveform {

   float  py;
   int yScaler = 100; // scale the height of the waves being drawn
   float step = 13;
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
