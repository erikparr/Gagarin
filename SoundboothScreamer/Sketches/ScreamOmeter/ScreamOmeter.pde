  /*Todo:
- difficulty w/ targetThresh
*/
import ddf.minim.*; // audio library -- used for audio visualization only
import ddf.minim.ugens.*;
import oscP5.*;
import netP5.*;

PShape s;
OscP5 oscP5;
NetAddress myRemoteLocation;
int b1Val;
int b2Val;
int b3Val;
PFont font;
AudioPlayer player;
IntroScreen intro = new IntroScreen();
OutroScreen outro = new OutroScreen();
Highscore hiscore = new Highscore();
public Panel panel = new Panel();
public Waveform wave = new Waveform();
public TargetWave tWave = new TargetWave();
// public LoudnessMonitor loud = new LoudnessMonitor();
public  Minim minim;
public  AudioInput in;
public  float targetFreq = 500;
public color EmRed =  color(254,0,12);
public color EmBlue =  color(12,71,157);
public color EmBlueGrad =  color(6,117,190);
public color EmCyan =  color(0,163,224);
public color EmBlue1 =  color(12,71,157,168);
public color EmLiteBlue =  color(196,222,243);
public color EmGrey =  color(90,90,90);
public color EmSea =  color(0,112,150);
public color EmSilver =  color(181,181,181);
public color EmSilver1 =  color(181,181,181,168);
public color EmYellow =  color(255,215,0);
public color EmYellow1 =  color(255,215,0,100);
public color EmBurgundy =  color(166,25,46);
public color EmRuby =  color(215,56,114);
public color EmAmber =  color(242,172,51);
public color EmVermilion =  color(240,88,34);
public color EmIndigo =  color(0,47,108);
public color EmGrad1 =  color(232,29,48);
public color EmGrad2 =  color(0,102,175);
public PVector tWavePos;
public PVector panelSize;
public float minFreq;
public float maxFreq;
public float currentHiscore;
public float playTimer;
public float tStampPlay;
public float outroTimer;
public float tStampOutro;
public float inFreq; // input frequency from Supercollider
float tStampTone=0;
String typetag;
float targetThresh;
Boolean hasWon =false; //set to true when game has been won
Boolean breakGlass =true; //set to true to send osc msg to SC to break glass on win
public Boolean startSound ;
public Boolean playIntro;
public Boolean playGame;
public Boolean playOutro;
public float gameDuration = 60;
Boolean receivedReadyMsg = false;
int errorMsgStamp =-10000; // for reporting receivedReadyMsg error
int difficultyMode=1; //0 = easy, 1 = medium, 2 = difficult
float outroTime = 10; //time on gameover/highscore screen

//boolean sketchFullScreen() {
//  return true;
//}

void setup() {
  size(1600, 900, P2D); // 1600 x 900
  noCursor();
  s = loadShape("logo.svg");
  smooth(8);
  // font = createFont("GillSans", 48);
  font = createFont("QTSqBd.otf", 110);
  minim = new Minim(this);
  in = minim.getLineIn();
  player = minim.loadFile("applause.aiff");
  textFont(font);
  textAlign(CENTER, CENTER);
  /*------------init classes ------------*/
  intro.init();
  outro.init();
  tWave.init();
  wave.init();
  /*------------OSC ------------*/
  oscP5 = new OscP5(this,47110);
  myRemoteLocation = new NetAddress("127.0.0.1",57120);
  b1Val = 1;
  b2Val = 1;
  b3Val = 1;
  /*------------other vars --------------------*/
  setDifficultyMode();
  tWavePos = new PVector(width/3, height/2);
  panelSize = new PVector(width*0.286, height);
  // loud.init(width/8, height/3, 50, 50);
  panel.init();
  hiscore.init(day(),month());
  resetGame();
  minFreq = targetFreq-targetThresh; //set min and max freq to target frequency from SC
  maxFreq = targetFreq+targetThresh;

}

void draw() {
  //setGradient(0, 0, width, height, EmBlue, EmCyan, 1);
   background(0);
   checkIfReady();
  if(playIntro){
    intro.update();
    }else if(playGame){
      pushStyle();
      // s.disableStyle();
      // fill(EmRed);
 popStyle();

      panel.wavePanel();
      playTimer = (millis()-tStampPlay)*0.001;

      if(playTimer>=gameDuration && playGame){
        //player has ran out of time, gameover
        playOutro=true;
        playGame=false;
        tStampOutro=millis();
        // println("start outro");
      }
      }else if(playOutro){
        outro();
        }else{
          pushStyle();
          fill(EmSilver);
          textAlign(CENTER, CENTER);
          text("START", width/2,height/2);
          popStyle();

        }

        if(startSound)
        oscStart();

        //display difficulty settings
        // if(playGame && playTimer<5){
        //   if(difficultyMode==0)
        //   text("Easy mode", 200,200);
        //   if(difficultyMode==1)
        //   text("Medium mode", 200,200);
        //   if(difficultyMode==2)
        //   text("Difficult mode", 200,200);
        // }

      }


      void setGradient(int x, int y, float w, float h, color c1, color c2, int axis ) {

        noFill();
        for (int i = x; i <= x+w; i++) {
          float inter = map(i, x, x+w, 0, 1);
          color c = lerpColor(c1, c2, inter);
          stroke(c);
          line(i, y, i, y+h);
        }
      }

      void checkIfReady(){
         if(millis()-errorMsgStamp<10000){
     pushStyle();
     fill(EmRed);
     textAlign(CENTER, CENTER);
     textSize(24);
     text("Not ready. Please notify attendant.",width/2,height-200);
     popStyle();
   }
}

      void oscEvent(OscMessage theOscMessage) {
        /* print the address pattern and the typetag of the received OscMessage */
        // println(theOscMessage.get(1).floatValue());
        //if receieve "isReady" is true (1), can start game, or else print message to screen
                if(theOscMessage.checkAddrPattern("/isReady")==true) {
//                  println("is ready: "+theOscMessage.get(0).floatValue());
                   if(int(targetFreq = theOscMessage.get(0).floatValue())==0)
                   receivedReadyMsg = false;
                   else
                   receivedReadyMsg = true;

                }
        if(theOscMessage.checkAddrPattern("/target")==true) {
          //get target frequency of glass from SC
          targetFreq = theOscMessage.get(0).floatValue();
          minFreq = targetFreq-targetThresh; //set min and max freq to target frequency from SC
          maxFreq = targetFreq+targetThresh;
        }
        if(theOscMessage.checkAddrPattern("/pitch")==true && targetFreq>0) {
          // typetag = theOscMessage.typetag();
          inFreq = theOscMessage.get(0).floatValue(); //
          // inFreq = targetFreq; //
        }
      }

      void sendOsc(String adrs, int val){
        OscMessage myMessage = new OscMessage(adrs);
        myMessage.add(val); /* add an int to the osc message */
        oscP5.send(myMessage, myRemoteLocation);
      }

      void oscStart(){
        sendOsc("/oscGameStart", b2Val);
        startSound = false;
      }

      void resetGame(){
        println("resetting");
        receivedReadyMsg = false;
        playIntro = false;
        playGame = false;
        playOutro = false;
        breakGlass = true; //set to true to send osc msg to SC to break glass on win
        startSound = false; // send osc msg to SC on game start
        hasWon =false; //set to true when game has been won
        intro.reset();
        hiscore.reset();
        panel.reset();
      }

      void outro(){
        outroTimer = (millis()-tStampOutro)*0.001;
        if(hasWon){
          println("hasHS: "+hasHighscore);
          if(hiscore.saveHighscore(playTimer) || hiscore.hasHighscore()){
            outroTime = 60; //show for longer duration;
            pushStyle();
            fill(EmSilver);
            textAlign(CENTER, CENTER);
            textSize(64);
            text("New record score!",width/2,height/2-(height/8));
            textSize(136);
            text(nf(playTimer, 2, 2) + " sec",  width/2,height/2);
            player.play();
            }else{
              outroTime = 5;
              pushStyle();
              fill(EmSilver);
              textAlign(CENTER, CENTER);
              textSize(64);
              text("Your score", width/2,height/2-(height/8));
              textSize(136);
              text(nf(playTimer, 2, 2) + " sec", width/2,height/2);
              popStyle();
            }
            if(breakGlass){
              sendOsc("/killTone", 1);
              breakGlass=false;
            }
            }else{
              outroTime = 10; //show for longer duration;
              sendOsc("/reset", 1);
              pushStyle();
              fill(EmSilver);
              textAlign(CENTER, CENTER);
              text("Sorry, try again later", width/2,height/2);
              popStyle();
            }
            println(outroTimer);
            if(outroTimer>=outroTime){
              resetGame();
              setDifficultyMode();
            }
          }

          void setDifficultyMode(){
            int ranVal = (int)random(100);
            //weighted randomness for difficulty settings
            // if(ranVal<50){
            //   difficultyMode=0;
            //   }else if(ranVal>50 && ranVal<90){
            //   difficultyMode=1;
            //   }else{
            //   difficultyMode=2;
            // }
            if(difficultyMode==0)
            targetThresh = random(10,20);
            if(difficultyMode==1)
            targetThresh = random(5,10);
            if(difficultyMode==2)
            targetThresh = random(1,6);
}
          //buttons in booth work like simulated keyboards
          void keyPressed() {
//tab is for record
            if (key == ' ') {
              println("tab");
              sendOsc("/1/toggle1", b1Val);
              if(b1Val==0)
              b1Val=1;
              else
              b1Val=0;
            }
            //q is for reference tone
            if (key == 'q') {
              if((millis()-tStampTone)>2000){ // player can only hear reference tone once every 2 seconds
              sendOsc("/oscRefTone", 1);
              tStampTone = millis();
            }
            }
            // 5 is to start game

            if (key == 'a') {
              if(receivedReadyMsg)
                playIntro = true;
                else
                errorMsgStamp = millis();
            }
            // XX is for easy mode
            if (key == '1') {
              difficultyMode = 0;
            }
            // xx is for medium
            if (key == 'c') {
              difficultyMode = 1;
            }
            // XX is for difficult
            if (key == '5') {
              difficultyMode = 2;
            }          }
