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

boolean sketchFullScreen() {
  return true;
}

void setup() {
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

void draw() {

  background(0);
  panel.update();
  wave.update();
  tWave.update();
  loud.update();
  update();

}

void update(){
  timer = initTime-millis();
  // tempFreq =map(sin(millis()*0.001),-1,1,450,550);
}

void oscEvent(OscMessage theOscMessage) {
  /* print the address pattern and the typetag of the received OscMessage */
// println(theOscMessage.get(1).floatValue());
tempFreq = theOscMessage.get(1).floatValue();
// waveY =  map(oscFreq, 0, targetFreq*2, height, 0);
}
