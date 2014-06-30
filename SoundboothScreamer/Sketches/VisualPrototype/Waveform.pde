 class Waveform {

   float  py;
   int step = 3; // num pixels spaced between each sample drawn
   float bufScaler = 0.666; // scale the audioBuffer drawn for smaller waveform
   int yScaler = 66; // scale the height of the waves being drawn


   void update()
   {
     noFill();
     // stroke(0, 255,208);
     stroke(EmBlue);
     // draw the waveforms so we can see what we are monitoring
     strokeWeight(2.5);  // Thicker
     for(int i = 0; i < (in.bufferSize()*0.88) - 1; i++)
     {
       line( i, in.left.get(i)*yScaler, i+step, py+in.left.get(i+step)*yScaler );
     }
   }

 }
