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

public void setup() {
  size(1280, 1040, P2D);
  font = loadFont("ArialMT-12.vlw");
  textFont(font, 32);

}

public void draw() {
  background(0);
  // text("ABC", 75, 350);
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
