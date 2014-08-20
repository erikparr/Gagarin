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

public class ScreamOmeter extends PApplet {

/*Todo:
- difficulty w/ targetThresh
*/
 // audio library -- used for audio visualization only




PShape s;
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
public  float targetFreq = 500;
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
public float currentHiscore;
public float playTimer;
public float tStampPlay;
public float outroTimer;
public float tStampOutro;
public float inFreq; // input frequency from Supercollider
float tStampTone=0;
String typetag;
float targetThresh;
Boolean hasWon =false; //set to true when game has been won
Boolean breakGlass =true; //set to true to send osc msg to SC to break glass on win
public Boolean startSound ;
public Boolean playIntro;
public Boolean playGame;
public Boolean playOutro;
public float gameDuration = 60;
int difficultyMode=1; //0 = easy, 1 = medium, 2 = difficult
float outroTime = 10; //time on gameover/highscore screen

public boolean sketchFullScreen() {
  return true;
}

public void setup() {
  size(1600, 900, P2D); // 1600 x 900
  noCursor();
  s = loadShape("logo.svg");
  smooth(8);
  // font = createFont("GillSans", 48);
  font = createFont("EMprintW01-Regular", 110);
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
  setDifficultyMode();
  tWavePos = new PVector(width/3, height/2);
  panelSize = new PVector(width*0.286f, height);
  // loud.init(width/8, height/3, 50, 50);
  panel.init();
  hiscore.init(day(),month());
  resetGame();
  minFreq = targetFreq-targetThresh; //set min and max freq to target frequency from SC
  maxFreq = targetFreq+targetThresh;

}

public void draw() {
  //setGradient(0, 0, width, height, EmBlue, EmCyan, 1);
   background(0);
   shape(s,width -(width/4), (height)-(height/4)+(height/10),263,50);
  //  text(map(mouseX,0,width,-100,100),100,100);
// text(mouseX+" "+mouseY,100,100);
  if(playIntro){
    intro.update();
    }else if(playGame){
      pushStyle();
      // s.disableStyle();
      // fill(EmRed);
 popStyle();

      panel.wavePanel();
      playTimer = (millis()-tStampPlay)*0.001f;

      if(playTimer>=gameDuration && playGame){
        //player has ran out of time, gameover
        playOutro=true;
        playGame=false;
        tStampOutro=millis();
        // println("start outro");
      }
      }else if(playOutro){
        outro();
        }else{
          pushStyle();
          fill(EmSilver);
          textAlign(CENTER, CENTER);
          text("Press Start", width/2,height/2);
          popStyle();
        }

        if(startSound)
        oscStart();

        //display difficulty settings
        // if(playGame && playTimer<5){
        //   if(difficultyMode==0)
        //   text("Easy mode", 200,200);
        //   if(difficultyMode==1)
        //   text("Medium mode", 200,200);
        //   if(difficultyMode==2)
        //   text("Difficult mode", 200,200);
        // }

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
          inFreq = theOscMessage.get(0).floatValue(); //
          // inFreq = targetFreq; //
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
        outroTimer = (millis()-tStampOutro)*0.001f;
        if(hasWon){
          println("hasHS: "+hasHighscore);
          if(hiscore.saveHighscore(playTimer) || hiscore.hasHighscore()){
            outroTime = 30; //show for longer duration;
            pushStyle();
            fill(EmSilver);
            textAlign(CENTER, CENTER);
            textSize(64);
            text("New high score!",width/2,height/2-(height/8));
            textSize(136);
            text(nf(playTimer, 2, 2) + " sec",  width/2,height/2);
            player.play();
            }else{
              outroTime = 5;
              pushStyle();
              fill(EmSilver);
              textAlign(CENTER, CENTER);
              textSize(64);
              text("Your score", width/2,height/2-(height/8));
              textSize(136);
              text(nf(playTimer, 2, 2) + " sec", width/2,height/2);
              popStyle();
            }
            if(breakGlass){
              sendOsc("/killTone", 1);
              breakGlass=false;
            }
            }else{
              outroTime = 10; //show for longer duration;
              sendOsc("/reset", 1);
              pushStyle();
              fill(EmSilver);
              textAlign(CENTER, CENTER);
              text("Sorry, try again later", width/2,height/2);
              popStyle();
            }
            println(outroTimer);
            if(outroTimer>=outroTime){
              resetGame();
              setDifficultyMode();
            }
          }

          public void setDifficultyMode(){
            int ranVal = (int)random(100);
            //weighted randomness for difficulty settings
            // if(ranVal<50){
            //   difficultyMode=0;
            //   }else if(ranVal>50 && ranVal<90){
            //   difficultyMode=1;
            //   }else{
            //   difficultyMode=2;
            // }
            if(difficultyMode==0)
            targetThresh = random(10,20);
            if(difficultyMode==1)
            targetThresh = random(5,10);
            if(difficultyMode==2)
            targetThresh = random(1,6);
}
          //buttons in booth work like simulated keyboards
          public void keyPressed() {
//tab is for record
            if (key == ' ') {
              println("tab");
              sendOsc("/1/toggle1", b1Val);
              if(b1Val==0)
              b1Val=1;
              else
              b1Val=0;
            }
            //q is for reference tone
            if (key == 'q') {
              if((millis()-tStampTone)>2000){ // player can only hear reference tone once every 2 seconds
              sendOsc("/oscRefTone", 1);
              tStampTone = millis();
            }
            }
            // 5 is to start game

            if (key == 'a') {
              playIntro = true;
            }
            // XX is for easy mode
            if (key == '1') {
              difficultyMode = 0;
            }
            // xx is for medium
            if (key == 'c') {
              difficultyMode = 1;
            }
            // XX is for difficult
            if (key == '5') {
              difficultyMode = 2;
            }          }
JSONObject highscore;
float defaultHighscore = 60;
Boolean hasHighscore=false;
class Highscore{

  public void init(int day, int month) {
    hasWon=false;
    highscore = loadJSONObject("highscore.json");
    String dateString = day+"-"+month;
    String date = highscore.getString("date");
    // if we're on a new day, reset the highscore to the default
    if(date.equals(dateString) == false){
      highscore.setFloat("score", defaultHighscore);
      highscore.setString("date", dateString);
      saveJSONObject(highscore, "data/highscore.json");
    }
    currentHiscore = highscore.getFloat("score"); // set current highscore from json file

  }

  public Boolean saveHighscore(float pScore){ //(int pScore, String pName, String pPhone)
// determine score ranking
    float score = highscore.getInt("score");
println("score: "+score+" player score: "+pScore);
    // String name = highscore.getString("name");
    // String phone = highscore.getString("phone");

    if(pScore<score){
      println("new high score");
      hasHighscore = true; // if we reached a high score, we record the info and break out from loop
      highscore.setFloat("score", pScore);
      }
      saveJSONObject(highscore, "data/highscore.json");
      return hasHighscore;
    }

  public float getCurrentHiscore(){
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
      panel.textTitles("Try to beat the high score", nf(currentHiscore,2,2)+" sec");
      pushMatrix();
      translate(width/2, height- height/4);
      panel.drawTimerPanel(lerp(0,currentHiscore, min(1.0f,(timer)-frame2)),false);
      popMatrix();
    }

if(timer>startTime){
  startSound = true;
  playGame = true;
  playIntro = false;
  println("start game");
  println(second());
}

  }

  public void reset(){
    isActive = false;
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
  // PImage logo;
  // PImage logoMsk;
  PShape s;
  Boolean isActive;
  // CamGrab camera = new CamGrab();

  public void init(){
      s = loadShape("logo.svg");
    rectMode(CORNER);
    textAlign(LEFT, CENTER);
    // camera.init();
    // logo = loadImage("logoSm.jpg");  // Load an image into the program
    // logoMsk = loadImage("logoSmMsk3.jpg");  // Load an image into the program
    // logo.mask(logoMsk);
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
    textAlign(CENTER,CENTER);
    fill(205);
    textSize(64);
    text(subTitle, width/2, height/2 - (height/8));
    textSize(136);
    text(title, width/2, height/2);
    popStyle();
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
    translate(0,map(inFreq,60,500,300,-300));
    wave.update();
    popMatrix();
    popMatrix();
    pushMatrix();
    translate( width/12 +86,(height)-(height/3.5f)+(height/10)+20);
    panel.drawTimerPanel(lerp(0,gameDuration,(millis()-tStampPlay)*(1/(gameDuration*1000))),true);
    popMatrix();
    fill(EmSilver);
    textSize(40);
    text(nf(playTimer, 2, 2), 27+width/12, (height)-(height/6));
    textSize(22);
    text(" sec", 194,785);
// image(logo,width -(width/4), (height)-(height/4)+(height/10));
  // s.disableStyle();
  // fill(255,255,255, map(mouseX, 0, width, 0, 255));
  // noStroke();
  // shape(s,width -(width/4), (height)-(height/4)+(height/10));
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
    int offset = 45;
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

  public void drawTimerPanel(float currentTime, boolean largeTimer){
    int inner = 100;
    int outer = 225;
    int tCol = 225;
    if(largeTimer){inner=125;outer=255;}
    pushStyle();
    noStroke();
    float offset = (1.5f*PI);
    fill(30);
    ellipse(0,0,outer,outer);
    fill(tCol);
    arc(0,0, outer, outer, 0+offset, map(currentTime, gameDuration, 0,(2*PI)+offset, 0+offset), PIE);
    fill(0);
    ellipse(0,0,inner,inner);
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
    line.setStrokeWeight(5);


  }

  public void update(Boolean active){
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
    stroke(255);

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

public void drawArrowUp(){
  pushMatrix();
  translate(width-(width/7),-100);
  stroke(255);
line(0,0,100,-100);
line(100,-100,200,0);
popMatrix();
}

public void drawArrowDown(){
  pushMatrix();
  translate(width-(width/7),100);

  stroke(255);
line(0,0,100,100);
line(100,100,200,0);
popMatrix();
}

    public void targetCount(){
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


    public void updateSinewave(){
      for(int i = 0; i<wavetable.length-1; i++) {
        wavetable[i]=sin((frameCount*0.225f)+i*0.01f);
        // wavetable[i] = wavetable[i+1];

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
     line.setStrokeWeight(5);
   }

   public void update()
   {

     noFill();
     // stroke(0, 255,208);
     strokeWeight(2.5f);
     // draw the waveforms so we can see what we are monitoring
     for(int i = 0; i < line.getVertexCount(); i++){
// line((i*step), in.right.get(i)*yScaler, (i*step)+(step/2), py+in.right.get(i+1)*yScaler );
    line.setVertex(i, (i*step), in.right.get(i)*yScaler);
     }
shape(line,0,0);
   }
 }
  static public void main(String[] passedArgs) {
    String[] appletArgs = new String[] { "ScreamOmeter" };
    if (passedArgs != null) {
      PApplet.main(concat(appletArgs, passedArgs));
    } else {
      PApplet.main(appletArgs);
    }
  }
}
