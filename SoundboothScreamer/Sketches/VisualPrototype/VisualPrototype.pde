/*Todo:
- difficulty w/ targetThresh
*/
import ddf.minim.*; // audio library -- used for audio visualization only
import ddf.minim.ugens.*;
import oscP5.*;
import netP5.*;

OscP5 oscP5;
NetAddress myRemoteLocation;
int b1Val;
int b2Val;
int b3Val;
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
public  float targetFreq = 0;
public color EmRed =  color(254,0,12);
public color EmBlue =  color(12,71,157);
public color EmBlueGrad =  color(6,117,190);
public color EmCyan =  color(0,163,224);
public color EmBlue1 =  color(12,71,157,168);
public color EmLiteBlue =  color(196,222,243);
public color EmGrey =  color(90,90,90);
public color EmSea =  color(0,112,150);
public color EmSilver =  color(181,181,181);
public color EmSilver1 =  color(181,181,181,168);
public color EmYellow =  color(255,215,0);
public color EmYellow1 =  color(255,215,0,100);
public color EmBurgundy =  color(166,25,46);
public color EmRuby =  color(215,56,114);
public color EmAmber =  color(242,172,51);
public color EmVermilion =  color(240,88,34);
public color EmIndigo =  color(0,47,108);
public color EmGrad1 =  color(232,29,48);
public color EmGrad2 =  color(0,102,175);
public PVector tWavePos;
public PVector panelSize;
public float minFreq;
public float maxFreq;
public float startTime;
public int currentHiscore;
float inFreq; // input frequency from Supercollider
float freqVal; // mapped inFreq value to screen height range
int initTime;
String typetag;
float targetThresh = 50;
Boolean hasWon =false; //set to true when game has been won
Boolean breakGlass =true; //set to true to send osc msg to SC to break glass on win

boolean sketchFullScreen() {
  return true;
}

void setup() {
  size(1920, 1080, P2D); // 1600 x 900
  // font = createFont("GillSans", 48);
  font = createFont("EMprintW01-Regular", 120);
  startTime = 10;
  initTime =  (int)(millis()*0.001)+(int)startTime; //90 seconds
  minim = new Minim(this);
  in = minim.getLineIn();
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
  panelSize = new PVector(width*0.286, height);

  // loud.init(width/8, height/3, 50, 50);
  panel.init();
  hiscore.init(day(),month());
}

void draw() {
  setGradient(0, 0, width, height, EmBlue, EmCyan, 1);
  // background(EmBlue);
// inFreq = map(sin(millis()*0.001),-1,1,targetFreq-100,targetFreq+100);

  timer = (millis()*0.001);

  if(intro.isActive() ){
    intro.update();
    }else if(!hasWon){
      tWave.setInputFreq(inFreq);
      panel.wavePanel();
    }else{
      text("you win", 100,100);
      if(breakGlass){
      sendOsc("/killTone", 1);
      breakGlass=false;
    }
    }

//     if(targetFreq>0){
// text("Target: " + targetFreq,100,100);
// text(inFreq,100,200);
// }
// text(frameRate,100,100);

  }


void setGradient(int x, int y, float w, float h, color c1, color c2, int axis ) {

  noFill();

    for (int i = x; i <= x+w; i++) {
      float inter = map(i, x, x+w, 0, 1);
      color c = lerpColor(c1, c2, inter);
      stroke(c);
      line(i, y, i, y+h);
    }
}


  void oscEvent(OscMessage theOscMessage) {
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
   freqVal = map(inFreq,0,targetFreq*2,height/3,-height/3);
  //    print("### received an osc message.");
  // print(" addrpattern: "+theOscMessage.addrPattern());
  // println(" typetag: "+theOscMessage.typetag());

  //  println(inFreq);
}
  // }
    // waveY =  map(oscFreq, 0, targetFreq*2, height, 0);
  }

void sendOsc(String adrs, int val){
  OscMessage myMessage = new OscMessage(adrs);
  myMessage.add(val); /* add an int to the osc message */
  oscP5.send(myMessage, myRemoteLocation);
}

  //buttons in booth work like simulated keyboards
    void keyPressed() {

    if (key == TAB) {
      println("Tab");
            sendOsc("/1/toggle1", b1Val);
            if(b1Val==0)
              b1Val=1;
              else
              b1Val=0;
    }
    if (key == 'q') {
            println("q");

            sendOsc("/1/toggle2", b2Val);
              if(b2Val==0)
              b2Val=1;
              else
              b2Val=0;

    }
    if (key == '5') {
            println("5");

            sendOsc("/1/toggle3", b3Val);
            if(b3Val==0)
              b3Val=1;
              else
              b3Val=0;
    }
}
