 class Waveform {

   Minim minim;
   AudioInput in;
   float px, py;
   int step = 3; // num pixels spaced between each sample drawn
   float bufScaler = 0.666; // scale the audioBuffer drawn for smaller waveform
   int yScaler = 66; // scale the height of the waves being drawn

   void init(float x, float y)
   {
     px = x;
     py = y;
     minim = VisualPrototype.minim;
     in = VisualPrototype.in;
   }

   void update()
   {
     // stroke(0, 255,208);
     py = max(map(tempFreq,0,600,height-height/3,height/3), height/3);
     stroke(21, 166, 223);
     // draw the waveforms so we can see what we are monitoring
     strokeWeight(2.5);  // Thicker
     for(int i = 0; i < (in.bufferSize()*0.88) - 1; i++)
     {
       line( px+i, py+in.left.get(i)*yScaler, px+i+step, py+in.left.get(i+step)*yScaler );
     }

   }

 }
