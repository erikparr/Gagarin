JSONObject highscore;
Boolean hasHighscore=false;
int defaultHighscore = 60;

class Highscore{

  void init(int day, int month) {
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

  void saveHighscore(int pScore){ //(int pScore, String pName, String pPhone)
    // determine score ranking
        int score = highscore.getInt("score");
        // String name = highscore.getString("name");
        // String phone = highscore.getString("phone");

        if(pScore>score){
          hasHighscore = true; // if we reached a high score, we record the info and break out from loop
          highscore.setInt("score", pScore);
          // highscore.setString("name", pName);
          // highscore.setString("phone", pPhone);
          print("HIGHSCORE!!  "+ pScore);
          }else{
            println( " :( ");
          }
      saveJSONObject(highscore, "data/highscore.json");
    }
  }
