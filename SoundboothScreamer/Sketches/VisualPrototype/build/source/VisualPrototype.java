import processing.core.*; 
import processing.data.*; 
import processing.event.*; 
import processing.opengl.*; 

import java.util.HashMap; 
import java.util.ArrayList; 
import java.io.File; 
import java.io.BufferedReader; 
import java.io.PrintWriter; 
import java.io.InputStream; 
import java.io.OutputStream; 
import java.io.IOException; 

public class VisualPrototype extends PApplet {

PFont font;
Panel panel = new Panel();

public float timer;
int initTime;

public void setup() {

  size(1280, 1040, P2D);
  font = createFont("GillSans", 48);
  textFont(font);
  textAlign(CENTER, CENTER);
  panel.init(width/4, height);

initTime = millis()+60000; //60 seconds
}

public void draw() {

  background(0);
  panel.update();
  update();

}

public void update(){
  timer = initTime-millis();
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
    fill(100);
    noStroke();
    rect(0,0,w,h);
    textBox();
  }

  public void textBox(){
    int px = 0;
    int py = h/8;
    int wd = w;
    int ht = 70;
    fill(50);
    noStroke();
    rect(px,py,wd,ht);
    fill(180,20,0);
    text("Countdown: "+ (int)VisualPrototype.this.timer/1000, px,py+(ht/2));
stopwatch(wd/2, h/3, 225,225);
  }

  public void stopwatch(int px, int py, int wd, int ht){
    float offset = (1.5f*PI);
    fill(200,0,0);
ellipse(px, py, wd, ht);
    fill(50,50,50);
arc(px, py, wd, ht, 0+offset, map(VisualPrototype.this.timer, 0, 60000, 0, (2*PI)+offset), PIE);
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
