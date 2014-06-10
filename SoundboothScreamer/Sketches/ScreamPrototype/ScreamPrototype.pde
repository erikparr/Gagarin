      //osc libs
      import oscP5.*;
      import netP5.*;

      OscP5 oscP5;
      PFont font;
      float oscFreq;
      //--sine wave setup
      int xspacing = 8;   // How far apart should each horizontal location be spaced
      int w;              // Width of entire wave

      float theta = 0.0;  // Start angle at 0
      float amplitude = 30.0;  // Height of wave
      float period = 200.0;  // How many pixels before the wave repeats
      float dx;  // Value for incrementing X, a function of period and xspacing
      float[] yvalues;  // Using an array to store height values for the wave
      float waveY = -100;
      float targetFreq = 280;
      int tStamp=0;
      int tCount=0;
      float aCol, rCol;
      boolean inRange = false;
      boolean goHigher = false;
      boolean goLower = false;
      boolean lockFreq = false;

      boolean sketchFullScreen() {
        return true;
      }

      void setup()
      {
        size(1280, 1040, P2D);
        rectMode(CORNERS);
        font = loadFont("ArialMT-12.vlw");
        textMode(SCREEN);
        /* start oscP5, listening for incoming messages at port 47110 */
        oscP5 = new OscP5(this,47110);
        //--sine wave
          w = width;
        dx = (TWO_PI / period) * xspacing;
        yvalues = new float[w/xspacing];


      }

      void draw()
      {
        smooth();
      //  fill(10,10,10, 40);  rect(0,0,width,height);  //draws a rectangle with alpha-40 so you get a fade effect
        background(10,10,10);                           //clears the screen, pick either this line or the previous line for the desired effect.
          calcWave();

        fill(rCol,100,0, aCol);
        rect(0,(height/2)-75, width, (height/2)+75);
        renderWave();
        playerWave();

        fill(70,70,75);
        rect(0,0,200,height);
        noFill();
        stroke(150,25,0);
        rect(0,0,200,height);

        noFill();
        stroke(255);
        pushMatrix();
        if(goHigher)
          fill(250,25,10);
        else
        noFill();
        translate(25, 350);
        triangle(0,75, 50, 0, 100, 75);
        popMatrix();

        pushMatrix();
              if(goLower)
          fill(250,25,10);
            else
                noFill();

        translate(25, 450);
        triangle(0,0, 50, 75, 100, 0);
        popMatrix();

        fill(255);
        text("Pitch detected: " + oscFreq , 5, 50);
        text("x:"+mouseX+" y:"+mouseY,5, 80);
        if((oscFreq > (targetFreq)-25) && (oscFreq < (targetFreq)+25) || lockFreq == true){
          if(!inRange)
            tStamp = millis();
          targetCount();
          inRange = true;
        }else{
                      inRange = false;
            aCol = 0;
            rCol = 0;

        }

          if(oscFreq < (targetFreq)-25){
            goHigher = true;
             goLower = false;

          }else if(oscFreq < (targetFreq)+25){
            goLower = true;
            goHigher = false;

  }

        // fill(255);
        // text("fuck yeah!!!!!!", 20,100);
        if(tCount>=5000)
          lockFreq = true;
      }

      void calcWave() {
        // Increment theta (try different values for 'angular velocity' here
        theta += 0.2;

        // For every x value, calculate a y value with sine function
        float x = theta;
        for (int i = 0; i < yvalues.length; i++) {
          yvalues[i] = sin(x)*amplitude;
          x+=dx;
        }
      }

      void renderWave() {
        noStroke();
        fill(255);
        // A simple way to draw the wave with an ellipse at each location
        for (int x = 0; x < yvalues.length; x++) {
          ellipse(x*xspacing, height/2+yvalues[x], 8, 8);
        }
      }

      void playerWave() {
        noStroke();
        fill(0,50,255);
        if(lockFreq==true)
          waveY = height/2;
        // A simple way to draw the wave with an ellipse at each location
        for (int x = 0; x < yvalues.length; x++) {
          ellipse(x*xspacing, waveY+yvalues[x], 8, 8);
        }
      }

      void targetCount(){
        tCount = millis()-tStamp;
        println(tCount);
        println(tStamp);
        println(millis());
        println("-");
        rCol = map(tCount, 0, 5000, 0, 255); // 5 second ramp
        aCol = map(tCount, 0, 5000, 0, 255);
      }

      void oscEvent(OscMessage theOscMessage) {
        /* print the address pattern and the typetag of the received OscMessage */
      // println(theOscMessage.get(1).floatValue());
      oscFreq = theOscMessage.get(1).floatValue();
      waveY =  map(oscFreq, 0, targetFreq*2, height, 0);
      }
