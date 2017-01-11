public class FoodSource {
  // internal state stored in location, vel and accel
  PVector location;
  PVector velocity;
  float r;        // radius 
  int hue;
  color col;         // colour  
  int id;
  float maxspeed;    // Maximum speed
  float size;
  float foodRemaining;
  float leftToGrow = 10.0;

  FoodSource(float x, float y, int _id) {
    maxspeed = 18;

    velocity = new PVector(random(-maxspeed, maxspeed), random(-maxspeed, maxspeed));
    location = new PVector(x, y);
    size = 0.1;
    id = _id;
    hue = (id*10)%360; 
    col = color(random(255), random(255), random(255), random(255));  // a cheap way to make a rainbow population - in HSB space, each agent will take a different colour
  }

  void display() {

    if (leftToGrow > 0) {
      size = size +0.3;
      location.x = location.x-0.15;
      location.y = location.y-0.15;  //to adjust for growing out of corners.

      leftToGrow = leftToGrow - 0.3;
    }
    fill(col);
    rect(location.x, location.y, size, size, size, size, size, size);   // draw the agent
  }

  public int computeMSE(int creatureX, int creatureY) {
    return (int) (((creatureX - location.x) * (creatureX - location.x) + (creatureY - location.y) * (creatureY - location.y)) / 2);
  }


  PVector getLocation() {
    return location;
  }

  float getLocationX() {
    return location.x;
  }

  float getLocationY() {
    return location.y;
  }
  boolean eatFood() {
    if (size > 0) {
      size--; 
      return true; //return true to indicate food has been eaten by the creature
    } else if (size < 0.9999) {
      return false;   //food was empty, none eaten
    }
    return false;
  }


  boolean emptyFoodSource() {
    if (size > 0) {
      return false;
    } else if (size < 0.4) {
      //delete food source from FoodSources arrayList

      int soundToPlay = int(random(2));
      if (soundToPlay == 0) {
        player_1_pop1.cue(0);
        player_1_pop1.play();
      } else if (soundToPlay == 1) {
        player_2_pop2.cue(0);
        player_2_pop2.play();
    }
    return true; //return true to indicate all food has been eaten
  }
  return false;
}
}

