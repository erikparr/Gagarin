/*Todo:
integrate with osc input from SC app:
-
*/
import ddf.minim.*; // audio library -- used for audio visualization only
import ddf.minim.ugens.*;
import oscP5.*;
import netP5.*;
import processing.video.*;

OscP5 oscP5;
PFont font;
IntroScreen intro = new IntroScreen();
OutroScreen outro = new OutroScreen();
public Panel panel = new Panel();
public Waveform wave = new Waveform();
public TargetWave tWave = new TargetWave();
// public LoudnessMonitor loud = new LoudnessMonitor();
public  Minim minim;
public  AudioInput in;
public  float timer;
public  float targetFreq = 250;
public color EmRed =  color(254,0,12);
public color EmBlue =  color(12,71,157);
public color EmBlueGrad =  color(6,117,190);
public color EmCyan =  color(0,163,224);
public color EmBlue1 =  color(12,71,157,168);
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
public int startTime;
float inFreq; // replace with real input from osc
int initTime;

boolean sketchFullScreen() {
  return true;
}

void setup() {
  size(1366, 768, P2D); // 1600 x 900
  // font = createFont("GillSans", 48);
  font = createFont("EMprintW01-Regular", 136);
  startTime = 10;
  initTime =  (int)(millis()*0.001)+startTime; //90 seconds
  intro.init();
  outro.init();
  tWave.init();
  textFont(font);
  textAlign(CENTER, CENTER);
  minim = new Minim(this);
  in = minim.getLineIn();

  /* start oscP5, listening for incoming messages at port 47110 */
  oscP5 = new OscP5(this,47110);

  tWavePos = new PVector(width/3, height/2);
  panelSize = new PVector(width*0.286, height);

  minFreq = targetFreq-200; //set min and max freq to target frequency from SC
  maxFreq = targetFreq+200;
  // loud.init(width/8, height/3, 50, 50);
  panel.init();
}

void draw() {

  setGradient(0, 0, width, height, EmBlue, EmCyan, 1);

  timer = (millis()*0.001);

  if(intro.isActive()){
    intro.update();
    }else{
      tWave.setInputFreq(inFreq);
      panel.wavePanel();
    }
    // if(timer<0)
    // outro.update();

  }

  void updateElements(){

    background(0);
    // panel.updateWindow(panelSize.x, panelSize.y, false);

    pushMatrix();
    // panel.drawTimerPanel(timer, false);
    // popMatrix();

    // pushMatrix();
    // translate(tWavePos.x,tWavePos.y-height*0.39);
    // panel.waveWindow(false);
    // popMatrix();

    // pushMatrix();
    // translate(tWavePos.x,tWavePos.y);
    // pushMatrix();
    // translate(0,-height*0.39);
    // panel.waveWindow(false);
    // popMatrix();
    panel.wavePanel();
    popMatrix();



  }

void setGradient(int x, int y, float w, float h, color c1, color c2, int axis ) {

  noFill();

    for (int i = x; i <= x+w; i++) {
      float inter = map(i, x, x+w, 0, 1);
      color c = lerpColor(c1, c2, inter);
      stroke(c);
      if(i==w/2)
      println(red(c)+" "+green(c)+" "+blue(c));
      line(i, y, i, y+h);
    }
}


  void oscEvent(OscMessage theOscMessage) {
    /* print the address pattern and the typetag of the received OscMessage */
    // println(theOscMessage.get(1).floatValue());
    inFreq = theOscMessage.get(1).floatValue();
    // waveY =  map(oscFreq, 0, targetFreq*2, height, 0);
  }
