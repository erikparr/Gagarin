 
import oscP5.*;
import netP5.*;
  
OscP5 oscP5;
NetAddress myRemoteLocation;
int b1Val;
int b2Val;
int b3Val;

void setup() {
  size(400,400);
  frameRate(25);
  oscP5 = new OscP5(this,47100);
  myRemoteLocation = new NetAddress("127.0.0.1",57120);
  b1Val = 1;
  b2Val = 1;
  b3Val = 1;  
}


void draw() {
  background(0);  
}
    void keyPressed() {

    if (key == TAB) {
      println("Tab");
            oscMsg("/1/toggle1", b1Val);
            if(b1Val==0)
              b1Val=1;
              else
              b1Val=0;
    }      
    if (key == 'q') {
            println("q");

            oscMsg("/1/toggle2", b2Val);
              if(b2Val==0)
              b2Val=1;
              else
              b2Val=0;

    }
    if (key == '5') {
            println("5");

            oscMsg("/1/toggle3", b3Val);
            if(b3Val==0)
              b3Val=1;
              else
              b3Val=0;
    }
}

//void oscMsg(String adrs, int val){
//  OscMessage myMessage = new   OscMessage("/test");
//  
//  myMessage.add(123); /* add an int to the osc message */
//  myMessage.add(12.34); /* add a float to the osc message */
//  myMessage.add("some text"); /* add a string to the osc message */
//  myMessage.add(new byte[] {0x00, 0x01, 0x10, 0x20}); /* add a byte blob to the osc message */
//  myMessage.add(new int[] {1,2,3,4}); /* add an int array to the osc message */
//
//  /* send the message */
//  oscP5.send(myMessage, myRemoteLocation); 
//}
void oscMsg(String adrs, int val){
  OscMessage myMessage = new OscMessage(adrs);  
  myMessage.add(val); /* add an int to the osc message */
  oscP5.send(myMessage, myRemoteLocation); 
}    

/* incoming osc message are forwarded to the oscEvent method. */
void oscEvent(OscMessage theOscMessage) {
  /* print the address pattern and the typetag of the received OscMessage */
  print("### received an osc message.");
  print(" addrpattern: "+theOscMessage.addrPattern());
  println(" typetag: "+theOscMessage.typetag());
}
