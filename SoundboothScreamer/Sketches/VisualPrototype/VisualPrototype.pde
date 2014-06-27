/*Todo:
integrate with osc input from SC app:
-
*/
import ddf.minim.*; // audio library -- used for audio visualization only
import ddf.minim.ugens.*;
import oscP5.*;
import netP5.*;

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
public color EmRed =  color(254,0,12);
public color EmBlue =  color(12,71,157);
public color EmBlue1 =  color(12,71,157,168);
public color EmGrey =  color(90,90,90);
public color EmSilver =  color(181,181,181);
public color EmSilver1 =  color(181,181,181,168);
public color EmYellow =  color(255,215,0);
public color EmBurgundy =  color(166,25,46);
public color EmRuby =  color(215,56,114);
public color EmAmber =  color(242,172,51);
public color EmVermilion =  color(240,88,34);
public color EmIndigo =  color(0,47,108);
public color EmGrad1 =  color(232,29,48);
public color EmGrad2 =  color(0,102,175);
public PVector wavePos;
public PVector tWavePos;
public PVector panelPos;
int initTime;
boolean sketchFullScreen() {
  return true;
}

void setup() {
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

void draw() {

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

tempFreq = map(sin(millis()*0.001),-1,1,0,600);
}

void oscEvent(OscMessage theOscMessage) {
  /* print the address pattern and the typetag of the received OscMessage */
  // println(theOscMessage.get(1).floatValue());
  tempFreq = theOscMessage.get(1).floatValue();
  // waveY =  map(oscFreq, 0, targetFreq*2, height, 0);
}
