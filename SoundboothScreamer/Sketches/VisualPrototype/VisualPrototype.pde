/*Todo:
integrate with osc input from SC app:
-
*/
import ddf.minim.*; // audio library -- used for audio visualization only
import ddf.minim.ugens.*;

PFont font;
Panel panel = new Panel();
Waveform wave = new Waveform();
TargetWave tWave = new TargetWave();
LoudnessMonitor loud = new LoudnessMonitor();
int targetFreq = 500; // replace with
public static float tempFreq=0; // replace with real input from osc
public static Minim minim;
public static AudioInput in;
public static float timer;
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
  tempFreq =map(sin(millis()*0.001),-1,1,450,550);
}
