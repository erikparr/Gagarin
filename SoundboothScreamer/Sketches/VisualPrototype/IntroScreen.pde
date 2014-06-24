class IntroScreen{
int timeCount;
int introTimer;

void init(){
timeCount = second()+10;
}

void update(){
  background(0);
  introTimer = timeCount-second();
  textSize(96);
text(introTimer, width/2, height/2);

}

boolean isActive(){
  if(introTimer>=0)
  return true;
  else
  return false;
}

//return intro duration in seconds
int getIntroDuration(){
  return introTimer;
}
}
