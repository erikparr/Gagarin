class Waveform {

  Minim minim;
  AudioInput in;
  int px, py;
  int step = 3; // num pixels spaced between each sample drawn
  float bufScaler = 0.666; // scale the audioBuffer drawn for smaller waveform
  int yScaler = 66; // scale the height of the waves being drawn

  void init(int x, int y)
  {
    px = x;
    py = y;
    minim = new Minim(this);

    // use the getLineIn method of the Minim object to get an AudioInput
    in = minim.getLineIn();
  }

  void update()
  {
    stroke(0);
    fill(0);
    ellipse(width/8, height/3, 100+((float)in.mix.level())*1000, 100+((float)in.mix.level())*1000);
    // stroke(0, 255,208);
    stroke(21, 166, 223);
    // draw the waveforms so we can see what we are monitoring
    strokeWeight(2.5);  // Thicker
    for(int i = 0; i < (in.bufferSize()*0.88) - 1; i++)
    {
      line( px+i, py+in.left.get(i)*yScaler, px+i+step, py+in.left.get(i+step)*yScaler );
    }

  }

}
