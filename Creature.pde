class Creature {
  // internal state stored in location, vel and accel
  PVector location;
  PVector velocity;
  PVector acceleration;
  float r;        // radius 
  float maxforce;    // Maximum steering force 
  float maxspeed;    // Maximum speed
  color col;         // colour  
  int id;
  int foodEaten;
  boolean reproductionDecrement= false;
  int starvationLevel;
  int fadeOutTimer;
  float starvationShrinklevel;
  boolean starving;
  int reproductuionDecrementCounter;

  int[] genotypes = new int[15];
  int[] target_array = new int[4];

  Creature(float x, float y, color random_colour, int id_number) {
    maxspeed = 3.5;  //4
    maxforce = 0.15;

    foodEaten = 0;

    acceleration = new PVector(0, 0);
    velocity = new PVector(random(-maxspeed, maxspeed), random(-maxspeed, maxspeed));
    location = new PVector(x, y);
    r = 20;    //20
    id = id_number;
    col = random_colour;  

    target_array[0] = 0;
    target_array[1] = 1;
    target_array[2] = 2;
    target_array[3] = 1;
  }

  // Method to update location
  void update() {
    // Update velocity
    velocity.add(acceleration);
    // Limit speed
    velocity.limit(maxspeed);
    location.add(velocity);
    // Reset accelerationelertion to 0 each cycle
    acceleration.mult(0);
    checkBoundaryNonTorroidal();
  }

  // constrain movement to the page - we've drawn a little fence inside the canvas so you can see what's going on at the edges
  void checkBoundaryNonTorroidal() {

    if ((location.x > width-1) || (location.x < 1)) {
      velocity.x = velocity.x * -1;
    }
    if ((location.y > height-1) || (location.y < 1)) {
      velocity.y = velocity.y * -1;
    }
  }

  void applyForce(PVector force) {
    acceleration.add(force);
  }

  void seek(PVector target) {
    PVector desired = PVector.sub(target, location);  // A vector pointing from the location to the target

    // Scale to maximum speed
    desired.setMag(maxspeed);

    // Steering = Desired minus velocity
    PVector steer = PVector.sub(desired, velocity);
    steer.limit(maxforce);  // Limit to maximum steering force
    applyForce(steer);
  }

  void display() {
    starvationLevel++;

    if (fadeOutTimer >= 1) {
      r= r - starvationShrinklevel;
      fadeOutTimer--;
    }

    float centralEllipseSize = ((long)100/100*foodEaten)/4;     //increment so closer to reproducing, larger the inside ellipse gets

    if (centralEllipseSize > r) {
      centralEllipseSize = r;
    }
    if (centralEllipseSize > 20) {
      centralEllipseSize = 20;
    }

    ellipse(location.x, location.y, centralEllipseSize, centralEllipseSize);  // Draw gray ellipse using CENTER mode
    fill(col);

    if (reproductionDecrement == true && reproductuionDecrementCounter < 100) {
      r = r - starvationShrinklevel/9;
     
     if (maxspeed > 2) { maxspeed = maxspeed + 0.001; }      
      reproductuionDecrementCounter++;
    } else {
      reproductuionDecrementCounter = 0;
      reproductionDecrement = false;
    }

      ellipse(location.x, location.y, r, r);   // draw the agent
      fill(col);
    
  }

  int getFoodEaten() {
    return foodEaten;
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

  void increaseSize() {
    r = r+0.2;
  }

  void incrementFoodEaten() {
    foodEaten++;
    starvationLevel = 0;
    if (maxspeed > 1.5) {
      maxspeed = maxspeed - 0.0001;
    }
  }

  void decreaseMaxSpeed() {
    maxspeed = maxspeed-(maxspeed/250);
  }

  float getSize() {
    return r;
  }

  public int computeMSE(int creatureX, int creatureY) {
    return (int) (((creatureX - location.x) * (creatureX - location.x) + (creatureY - location.y) * (creatureY - location.y)) / 2);
  }

  void reproduced() {
    foodEaten = foodEaten = 0;
    reproductionDecrement = true;
    setShrinkLevel();
  }

  int getStarvationLevel() {
    return starvationLevel;
  }


  void beginStarvationAnimation() {
    setShrinkLevel();
    fadeOutTimer = 200;
    starving = true;
    maxspeed = 0.3;
  }

  boolean getStarving() {
    return starving;
  }

  int getFadeOutLevel() {
    return fadeOutTimer;
  }

  void setShrinkLevel() {
    starvationShrinklevel = r/200;
  }

  float getSpeed() {
    return maxspeed;
  }

  void addGenotype(int arrayIndex, int newGenotype) {
    genotypes[arrayIndex] = newGenotype;
  }

  int returnGenotype(int arrayIndex) {
    return genotypes[arrayIndex];
  }

int[] returnGenotypeArray() {
  return genotypes;
}

  int getFitness() {
    int fitnessCounter = 0;
    for (int i = 0; i < 4; i++) {              //for each genotype (character)
      if ( genotypes[i] == target_array[i]) {  //if the letter in the genotype matches that of the target array
        fitnessCounter++;                      //add one to the counter
      }
    }
    return fitnessCounter;
  }

  color returnColour() {
    return col;
  }
}

