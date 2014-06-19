class LoudnessMonitor {

  AudioInput in;
  float amp;
  float avg;
  float flashFreq =0;
  String loudMsg="";
  int wd, ht, px, py;
  float[] avgAmp = new float[128]; // store the last 1024 amplitude values in an array, to get average
  float flashCol;

  void init(int x, int y, int width, int height){
    in = VisualPrototype.in;
    wd = width;
    ht = height;
    px = x;
    py = y;
  }

  void update(){
    pushMatrix();
// stroke(0);
// fill(65*0.6,70*0.6,80*0.6);
// rect(0,0,mouseX,mouseY,7);

    calcLoudness();
    calcAverage();
    translate(px,py);
    textSize(42);
    fill(200);
    text(loudMsg, -wd*3,-ht*3);

    noFill();
    stroke(150);
    amp = in.mix.level();
// fill(color(flashCol, flashCol,flashCol));
fill(65*0.8,70*0.8,80*0.8);

noStroke();
fill(50,150,50,50);
ellipse(0,0,100,100);
fill(150,50,50,50);
ellipse(0,0,200,200);
stroke(0);
    fill(color(map(avg,0.001,0.03,50,255), 50,50));
    if(flashCol==255)
    flashCol =50;

    ellipse(0, 0, min(wd+amp*1000,200), min(ht+amp*1000,200));
    loudnessText();

    popMatrix();
  }

  void calcAverage(){
    float sum=0;
    avgAmp[avgAmp.length-1] = amp;

    for(int i = 0; i<avgAmp.length-1; i++) {
      avgAmp[i] = avgAmp[i+1];
      sum = (sum+avgAmp[i]);
    }

    avg = sum/avgAmp.length;
    flashFreq = flashFreq+ avg;
    if(flashFreq>0.1){
      flashCol = 255;
      flashFreq=0;
    }

  }
  void calcLoudness(){

  }

  void loudnessText(){

    if(avg>0.002){
      loudMsg = "so very quiet....";
    }
    if(avg>0.01){
      loudMsg = "not very loud....";
    }
    if(avg>0.02){
      loudMsg = "pretty loud....";
    }
    if(avg>0.03){
      loudMsg = "fucking loud!!!";
    }
    if(avg<0.002){
      loudMsg = "silencio...";

    }

  }
}
