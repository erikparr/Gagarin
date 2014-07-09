JSONArray vals;
Boolean hasHighscore=false;

class Highscore{

  void init() {

    vals = loadJSONArray("highscore.json");
  }

  void saveHighscore(int pScore, String pName, String pPhone){

    // determine score ranking
    for (int i = 0; i < vals.size(); i++) {

      if(!hasHighscore){
        JSONObject highscore = vals.getJSONObject(i);

        int id = highscore.getInt("rank", i);
        int score = highscore.getInt("score");
        String name = highscore.getString("name");
        String phone = highscore.getString("phone");

        if(pScore<score){
          hasHighscore = true; // if we reached a high score, we record the info and break out from loop
          highscore.setInt("score", pScore);
          highscore.setString("name", pName);
          highscore.setString("phone", pPhone);
          vals.setJSONObject(i, highscore);
          print("HIGHSCORE!! --- "+ id + ", " + pName + ", " + pPhone + ", " + pScore);
        }else{
        println(id + ", " + name + ", " + phone + ", " + score);
      }
      }
    }
    saveJSONArray(vals, "data/highscore.json");

  }



}
