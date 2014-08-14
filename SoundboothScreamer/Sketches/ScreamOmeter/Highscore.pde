JSONObject highscore;
int defaultHighscore = 60;
Boolean hasHighscore=false;
class Highscore{

  void init(int day, int month) {
    hasWon=false;
    highscore = loadJSONObject("highscore.json");
    String dateString = day+"-"+month;
    String date = highscore.getString("date");
    // if we're on a new day, reset the highscore to the default
    if(date.equals(dateString) == false){
      highscore.setInt("score", defaultHighscore);
      highscore.setString("date", dateString);
      saveJSONObject(highscore, "data/highscore.json");
    }
    currentHiscore = highscore.getInt("score"); // set current highscore from json file

  }

  Boolean saveHighscore(int pScore){ //(int pScore, String pName, String pPhone)
// determine score ranking
    int score = highscore.getInt("score");
println("score: "+score+" player score: "+pScore);
    // String name = highscore.getString("name");
    // String phone = highscore.getString("phone");

    if(pScore<score){
      println("new high score");
      hasHighscore = true; // if we reached a high score, we record the info and break out from loop
      highscore.setInt("score", pScore);
      }
      saveJSONObject(highscore, "data/highscore.json");
      return hasHighscore;
    }

  int getCurrentHiscore(){
    return currentHiscore;
  }

  Boolean hasHighscore(){
    return hasHighscore;
  }

  void reset(){
    hasHighscore=false;
  };
  }
