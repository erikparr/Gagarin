 class Waveform {

   float  py;
   int yScaler = 100; // scale the height of the waves being drawn
   float step = 2.666;

   void update()
   {
     noFill();
     // stroke(0, 255,208);
     stroke(EmBlue);
     // draw the waveforms so we can see what we are monitoring
     strokeWeight(2.5);  // Thicker
     for(int i = 0; i < (in.bufferSize()*0.5)-1; i++){
       line((i*step), in.left.get(i)*yScaler, (i*step)+(step/2), py+in.left.get(i+1)*yScaler );
     }
   }

 }
