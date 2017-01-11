import ddf.minim.*;

ArrayList<Creature> creaturesList = new ArrayList<Creature>();
ArrayList<Creature> childCreaturesList = new ArrayList<Creature>();
ArrayList<Creature> starvedCreaturesList = new ArrayList<Creature>();


int population = 20;
static  int idCounter = 1;
static  int foodIdCounter = 0;
static int drawCounter = 0;
int creatureNumber = 10;
int foodRequiredToMate = 100;
ArrayList<String> creaturesToCreate = new ArrayList<String>();
ArrayList<FoodSource> foodSources = new ArrayList<FoodSource>();
int t = 230;
boolean up = true;

Minim minim;
AudioPlayer player_1_pop1;
AudioPlayer player_2_pop2;
AudioPlayer player_3_pop3;

AudioPlayer player_synthc1;
AudioPlayer player_synthc2;
AudioPlayer player_synthc3;
AudioPlayer player_synthc4;

AudioPlayer player_synthd1;
AudioPlayer player_synthd2;
AudioPlayer player_synthd3;
AudioPlayer player_synthd4;

AudioPlayer player_synthe1;
AudioPlayer player_synthe2;
AudioPlayer player_synthe3;
AudioPlayer player_synthe4;


void setup() {
  size(550, 550);
  colorMode(RGB);

  //create initial creatures
  for (int i= 0; i < population; i++) {
    color colour_random = color(random(255), random(255), random(255), random(40, 200)); 

    creaturesList.add(new Creature(random(1, 549), (random(1, 549)), colour_random, idCounter));
    idCounter++;

  }

  //---------------
  //fills genotypes array with random values
  for (Creature c : creaturesList) { 
    for (int j = 0; j < 4; j++) {
      c.addGenotype(j, (int)random(0, 3));
    }
  }



  minim = new Minim(this);
  player_1_pop1 = minim.loadFile("pop1.wav");  //pop noises played when food is eaten
  player_2_pop2 = minim.loadFile("pop2.wav");

  player_synthc1 = minim.loadFile("synthc.wav");
  player_synthc2 = minim.loadFile("synthc.wav");
  player_synthc3 = minim.loadFile("synthc.wav");
  player_synthc4 = minim.loadFile("synthc.wav");

  player_synthd1 = minim.loadFile("synthd.wav");
  player_synthd2 = minim.loadFile("synthd.wav");
  player_synthd3 = minim.loadFile("synthd.wav");
  player_synthd4 = minim.loadFile("synthd.wav");

  player_synthe1 = minim.loadFile("synthe.wav");
  player_synthe2 = minim.loadFile("synthe.wav");
  player_synthe3 = minim.loadFile("synthe.wav");
  player_synthe4 = minim.loadFile("synthe.wav");
}

void draw() {
  System.gc ();
  System.runFinalization ();
  background(210, 81, 88, 3);
  drawCounter++;


  //make food appear
  if ( drawCounter % 2 == 1 && foodSources.size() < 50) {

    foodSources.add(new FoodSource(random(10, 539), (random(10, 539)), foodIdCounter));
    foodSources.add(new FoodSource(random(10, 539), (random(10, 539)), foodIdCounter));
    foodSources.add(new FoodSource(random(10, 539), (random(10, 539)), foodIdCounter));
    foodIdCounter = foodIdCounter+1;
  }
  //displaying food on screen
  for (int i = 0; i < foodSources.size (); i++) { 
    foodSources.get(i).display();
  }

  //------- add child created to creatureList

  if (childCreaturesList.size() != 0) {
    for (int k = 0; k < childCreaturesList.size (); k++) {
      creaturesList.add(childCreaturesList.get(k));
      childCreaturesList.remove(k);
    }
  }

  //------- added starving creatures to list so can be removed
  if (starvedCreaturesList.size() != 0) {
    for (int k = 0; k < starvedCreaturesList.size (); k++) {
      int starvedCreatureIndex = creaturesList.indexOf(starvedCreaturesList.get(k));

      creaturesList.remove(starvedCreatureIndex);
      //System.out.println("removed: creature ");

      starvedCreaturesList.remove(k);
    }
  }

  //----------------

  // Call the appropriate steering behaviors for our agents
  if (creaturesList.size() > 0) {
    for (Creature c : creaturesList) { //update creatures behaviour

      if (c.getStarvationLevel() > 100000 && c.getStarving() == false) {  //add if movement speed too slow.
        c.setShrinkLevel();

        c.beginStarvationAnimation();
      }

      if ( c.getFadeOutLevel() == 1) {
        starvedCreaturesList.add(c);
        break;
      }

      if (c.getFoodEaten() >= foodRequiredToMate && findNearestPartner(c) != null) {     //if eaten enough food look for partner
        Creature partner = findNearestPartner(c);
        //----------------------
        //check if on top of partner, ready to mate
        if (c.getLocationX() < partner.getLocationX() +(((int)c.getSize()/2)) && c.getLocationX() > partner.getLocationX() -((int)c.getSize()/2) && partner.getFadeOutLevel() == 0 && c.getFadeOutLevel() == 0) {  //if within range of partner
          if (c.getLocationY() < partner.getLocationY() +(((int)c.getSize()/2)) && c.getLocationY() > partner.getLocationY() -((int)c.getSize()/2)) {

            //check fitness levels of both creatures
            int creatureFitness = c.getFitness();
            int partnerFitness = partner.getFitness();

            System.out.println("creature fitness: " + creatureFitness);
            System.out.println("partner fitness: " + partnerFitness + "\n");

            // -------------- reproduction --------
            if ( creatureFitness > partnerFitness) {  //if first creature is fitter than its partner
              Creature child = new Creature(c.getLocationX(), c.getLocationY(), c.returnColour(), idCounter);  //create a child from the first creature
              idCounter++;

              //setup genes of child
              for (int i = 0; i < 4; i++) {
                child.addGenotype(i, c.returnGenotype(i));  //copy the parent's genes
              }

              //mutate a single incorrect gene
              int randomSelectedGene = (int)random(0, 4);                //select random gene from larger genotype
              child.addGenotype(randomSelectedGene, (int)random(0, 3));  //mutates the gene to a new value

              //add to child so can be added to creaturesList after finishing this iteration of it
              childCreaturesList.add(child);  

              playSound(child.returnGenotypeArray());  //plays the tune described by the genes
              partner.beginStarvationAnimation();  //kill off partner
              c.reproduced();                      //add effects to surviving creature
            } else if ( partnerFitness > creatureFitness) {
              Creature child = new Creature(partner.getLocationX(), partner.getLocationY(), partner.returnColour(), idCounter);  //create a child from the first creature
              idCounter++;

              //setup genes of child
              for (int i = 0; i < 4; i++) {
                child.addGenotype(i, partner.returnGenotype(i));  //copy the parent's genes
              }

              //mutate a single incorrect gene
              int randomSelectedGene = (int)random(0, 4);                //select random gene from larger genotype
              child.addGenotype(randomSelectedGene, (int)random(0, 3));  //mutates the gene to a new value

              //add to child so can be added to creaturesList after finishing this iteration of it
              childCreaturesList.add(child);  

              playSound(child.returnGenotypeArray());  //plays the tune described by the genes
              c.beginStarvationAnimation();  //kill off partner
              partner.reproduced();                      //add effects to surviving creature
            } else if ( partnerFitness == 4 && creatureFitness == 4) {  //if both at solution
              Creature child = new Creature(c.getLocationX(), c.getLocationY(), c.returnColour(), idCounter);  //create a child from the first creature
              idCounter++;

              //setup genes of child
              for (int i = 0; i < 4; i++) {
                child.addGenotype(i, c.returnGenotype(i));  //copy the parent's genes
              }

              //do not make any mutations


              //add to child so can be added to creaturesList after finishing this iteration of it
              childCreaturesList.add(child);  

              playSound(child.returnGenotypeArray());  //plays the tune described by the genes
              partner.beginStarvationAnimation();  //kill off partner
              c.reproduced();                      //add effects to surviving creature
            } else if ( partnerFitness == creatureFitness) {  //if both equal but not at optimal solution
              Creature child = new Creature(c.getLocationX(), c.getLocationY(), c.returnColour(), idCounter);  //create a child from the first creature
              idCounter++;

              //setup genes of child
              for (int i = 0; i < 4; i++) {
                child.addGenotype(i, c.returnGenotype(i));  //copy the parent's genes
              }

              //mutate a single incorrect gene
              int randomSelectedGene = (int)random(0, 4);                //select random gene from larger genotype
              child.addGenotype(randomSelectedGene, (int)random(0, 3));  //mutates the gene to a new value

              //add to child so can be added to creaturesList after finishing this iteration of it
              childCreaturesList.add(child);  

              playSound(child.returnGenotypeArray());  //plays the tune described by the genes
              partner.beginStarvationAnimation();  //kill off partner
              c.reproduced();                      //add effects to surviving creature
            }
          }
        }


        c.seek(partner.getLocation());  //location of nearest partner
        c.update();
        c.display();
      }     //else not eaten enough food, or no current partner available, instead look for nearest food source
      else if (c.getStarving() == false) { 
        //locate nearest food to creature
        FoodSource nearestFood = findNearestFoodSource(c);     //method to find nearest food source
        if (nearestFood != null) {  //if food currently on the map

          //check if creature is eating food -   if creature is within close distance of food
          if (c.getLocationX() < nearestFood.getLocationX() +(((int)c.getSize()/2)) && c.getLocationX() > nearestFood.getLocationX() -((int)c.getSize()/2)) {  //if within range of food
            if (c.getLocationY() < nearestFood.getLocationY() +(((int)c.getSize()/2)) && c.getLocationY() > nearestFood.getLocationY() -((int)c.getSize()/2)) {
              boolean foodEaten = nearestFood.eatFood();      //reduce food source by 1
              if (foodEaten == true) {
                c.incrementFoodEaten(); //increase creature eaten food by 1
                c.increaseSize(); //increase creature radius by 1
                c.decreaseMaxSpeed();             //decrease speed by 1
              }
              boolean foodEmpty = nearestFood.emptyFoodSource();  //returns if any food left within source 
              if (foodEmpty == true) {  //food source empty
                foodSources.remove(nearestFood);//delete food source
              }
            }
          }

          c.seek(nearestFood.getLocation());
          c.update();
          c.display();
        } else { /*if no food available*/
          c.seek(new PVector(random(0, 550), random(0, 550)));
          c.update();
          c.display();
        }
      } else { /*starving*/
        c.seek(new PVector(random(0, 550), random(0, 550)));
        c.update();
        c.display();
      }
    }
  }
}

public FoodSource findNearestFoodSource(Creature creature) {

  PVector currentLocation = creature.getLocation();

  FoodSource closestMatch = null;
  int bestMatchIndex;
  int minMSE = Integer.MAX_VALUE;
  int mse;

  for (FoodSource f : foodSources) {
    mse = f.computeMSE((int)currentLocation.x, (int)currentLocation.y);
    if (mse < minMSE) { //if a closer match
      minMSE = mse;
      closestMatch = /*foodSources.get(k)*/f;
      bestMatchIndex = foodSources.indexOf(f); //should return int array index
    }
  }
  if (closestMatch != null) {
    return closestMatch;
  } else {
    return null;  //return null
  }
}

public Creature findNearestPartner(Creature creature) {

  PVector currentLocation = creature.getLocation();
  Creature closestMatch = null;
  int bestMatchIndex;
  int minMSE = Integer.MAX_VALUE;
  int mse;

  for (Creature c : creaturesList) {
    if (c != creature && c.getFadeOutLevel() == 0) {
      if ( c.getFoodEaten() >= foodRequiredToMate) {
        mse = c.computeMSE((int)currentLocation.x, (int)currentLocation.y);
        if (mse < minMSE) { //if a closer match
          minMSE = mse;
          closestMatch = c;
          bestMatchIndex = foodSources.indexOf(c); //should return int array index
        }
      }
    }
  }

  if (closestMatch != null) {
    return closestMatch;
  } else {
    return null;  //return null
  }
}

int returnFoodRequiredToMate () {
  return foodRequiredToMate;
}


void playSound(int[] genes) {

  for (int i = 0; i < 4; i++) {
    if ( genes[i] == 0 ) {  //if note is a c
      if (i == 0) {  //if the first note
        player_synthc1.cue(0);
        player_synthc1.play();
      }
      if (i == 1) {
        player_synthc2.cue(300);
        player_synthc2.play();
      }
      if (i == 2) {
        player_synthc3.cue(600);
        player_synthc3.play();
      }
      if (i == 3) {
        player_synthc4.cue(900);
        player_synthc4.play();
      }
    }
    if ( genes[i] == 1 ) {  //if note is a d
      if (i == 0) {  //if the first note in the gene sequence
        player_synthd1.cue(0);
        player_synthd1.play();
      }
      if (i == 1) {
        player_synthd2.cue(300);
        player_synthd2.play();
      }
      if (i == 2) {
        player_synthd3.cue(600);
        player_synthd3.play();
      }
      if (i == 3) {
        player_synthd4.cue(900);
        player_synthd4.play();
      }
    }
    if ( genes[i] == 2 ) {  //if note is a e
      if (i == 0) {  //if the first note
        player_synthe1.cue(0);
        player_synthe1.play();
      }
      if (i == 1) {
        player_synthe2.cue(300);
        player_synthe2.play();
      }
      if (i == 2) {
        player_synthe3.cue(600);
        player_synthe3.play();
      }
      if (i == 3) {
        player_synthd4.cue(900);
        player_synthd4.play();
      }
    }
  }
}

