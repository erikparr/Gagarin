import processing.core.*; 
import processing.data.*; 
import processing.event.*; 
import processing.opengl.*; 

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

public class oscP5sendReceive extends PApplet {

/**
 * oscP5sendreceive by andreas schlegel
 * example shows how to send and receive osc messages.
 * oscP5 website at http://www.sojamo.de/oscP5
 */
 


  
OscP5 oscP5;
NetAddress myRemoteLocation;

public void setup() {
  size(400,400);
  frameRate(25);
  /* start oscP5, listening for incoming messages at port 12000 */
  oscP5 = new OscP5(this,47110);
  
  /* myRemoteLocation is a NetAddress. a NetAddress takes 2 parameters,
   * an ip address and a port number. myRemoteLocation is used as parameter in
   * oscP5.send() when sending osc packets to another computer, device, 
   * application. usage see below. for testing purposes the listening port
   * and the port of the remote location address are the same, hence you will
   * send messages back to this sketch.
   */
  // myRemoteLocation = new NetAddress("127.0.0.1",12000);
}


public void draw() {
  background(0);  
}

// void mousePressed() {
//   /* in the following different ways of creating osc messages are shown by example */
//   OscMessage myMessage = new OscMessage("/test");
  
//   myMessage.add(123); /* add an int to the osc message */

//   /* send the message */
//   oscP5.send(myMessage, myRemoteLocation); 
// }


/* incoming osc message are forwarded to the oscEvent method. */
public void oscEvent(OscMessage theOscMessage) {
  /* print the address pattern and the typetag of the received OscMessage */
println(theOscMessage.get(1).floatValue());
}
  static public void main(String[] passedArgs) {
    String[] appletArgs = new String[] { "oscP5sendReceive" };
    if (passedArgs != null) {
      PApplet.main(concat(appletArgs, passedArgs));
    } else {
      PApplet.main(appletArgs);
    }
  }
}
