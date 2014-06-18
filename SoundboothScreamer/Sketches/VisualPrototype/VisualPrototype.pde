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
int targetFreq = 500; // replace with
public float timer;
int initTime;

boolean sketchFullScreen() {
  return true;
}

void setup() {
  size(1440, 1040, P2D);
  font = createFont("GillSans", 48);
  textFont(font);
  textAlign(CENTER, CENTER);
  panel.init(width/4, height);
  wave.init(width/3, height/4);
  tWave.init(width/3, height/2);
  initTime = millis()+60000; //60 seconds
}

void draw() {

  background(0);
panel.update();
  wave.update();
  tWave.update();
  update();

}

void update(){
  timer = initTime-millis();
}
