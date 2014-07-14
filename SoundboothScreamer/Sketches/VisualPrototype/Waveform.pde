 class Waveform {

   float  py;
   int yScaler = 100; // scale the height of the waves being drawn
   float step = 10;
   PShape line;

   void init(){
     line = createShape();
     line.beginShape();
     line.noFill();
     line.stroke(EmYellow);
     for(int i=0; i<in.bufferSize()*0.15; i++){
       line.vertex(i,i,0);
     }
    //  println(line.getVertexCount());
     line.endShape();
   }

   void update()
   {
     noFill();
     // stroke(0, 255,208);
     strokeWeight(2.5);
     // draw the waveforms so we can see what we are monitoring
     for(int i = 0; i < line.getVertexCount(); i++){
// line((i*step), in.left.get(i)*yScaler, (i*step)+(step/2), py+in.left.get(i+1)*yScaler );
    line.setVertex(i, (i*step), in.left.get(i)*yScaler);
     }
shape(line,0,0);
   }
 }
