//See readme file for instructions, image/audio source and license information.

//import minim
import ddf.minim.*;

//Global variables - accessible to any method in the object
int a = 0;
int pinkX;
int pinkY;
int starX;
int starY;
int score;
int lives;
int flameX;
int flameY;
boolean gameover;
boolean inAir;
int airCount;
//Image objects for the sprites and backgrounds
PImage flame;
PImage[] mouth = new PImage[2];  //mouth images array
PImage mouth_ini;
PImage star;
PImage bg;
PImage bg2;
PImage bg3;
PImage game_over_splash;
PImage beatGame;

//call minim library and initialize audio player
Minim minim;
//AudioPlayer is the class and player, sound_lives, etc.. are objects instantiated versions of that class
AudioPlayer player;
AudioPlayer sound_lives;
AudioPlayer sound_score;
AudioPlayer game_over;
AudioPlayer triumph;

MouthPerson mouth1;

void setup() {
  
  //instatiate player object to use in the game
  mouth1 = new MouthPerson();
 
  size(1000, 600);
  star = loadImage("images/star.png");
  mouth_ini = loadImage("images/mouth_0.png");
  bg = loadImage("images/back_night.png");
  bg2 = loadImage("images/back_desert.png");
  bg3 = loadImage("images/back_jungle.png");
  flame = loadImage("images/flame.png");
  game_over_splash = loadImage("images/gameover.png");
  beatGame = loadImage("images/beat_game.png");
  flameX = int(random(50, 920));
  flameY = 0;
  starX = int(random (50, 920));
  starY = 0;
  score = 0;
  lives = 3;
  gameover = false;
 
  //load and loop through 2 images to animate the mouth  
  for (int i = 0; i < 2; i++) {
    String imageName = "images/mouth_" + nf(i, 1) + ".png";
    mouth[i] = loadImage(imageName);
    frameRate(15); //control speed of frame change
   }
  
  //pass this to Minim so that it can load files from the data directory
  minim = new Minim(this);
  
  // load audio files
  player = minim.loadFile("Bossa-nova-beat-music-loop.mp3");
  sound_lives = minim.loadFile("lives.mp3");
  sound_score = minim.loadFile("score.mp3");
  game_over = minim.loadFile("Game-over-robotic-voice.mp3");
  triumph = minim.loadFile("triumph_win.mp3");
  
  //loop to continuously play background music
  player.loop();
}

void draw() {
  if (gameover == true) {
    lives = 3;
    score = 0;
    image(game_over_splash, -310, -100);
    
    //WINNER IF REACH 12 
  } else if (score == 12) {
    player.pause();
    triumph.play();
    image(beatGame, -310, -100);
    
    if (keyCode == DOWN) {
      gameover = false;
      lives = 3;
      score = 0;
      player.loop();
    }  
    
    //go to different levels based on score by changing background image and increase speed of flames and stars in each level.
  } else {
    if (score < 4) { 
      image(bg, 0,0, 1000, 600);
      starY = starY + 11;
      flameY = flameY + 13;
    }
    
    if (score >= 4) { 
      image(bg2, 0,0, 1000, 600); 
      starY = starY + 14;
      flameY = flameY + 16;
    }
    
    if (score >= 8) { 
      image(bg3, 0,0, 1000, 600); 
      starY = starY + 15;
      flameY = flameY + 17;
    }
    
    //stars and flames
    image(star, starX, starY, 50, 50);
    image(flame, flameX, flameY, 50, 50);
    
    //show score and lives
    textSize(30);
    fill (255, 255, 255);
    text ("Score: "+ score, 20, 50);
    text ("Lives: "+ lives, 20, 90);
  
    //game over if less than 1 life and play gamover sound.
    if (lives < 1) { 
      gameover = true; 
      game_over.rewind();
      game_over.play();
    }
  
  //Load tjhe proper image depending on if he is moving or still
  if(keyPressed) {
      image(mouth[a], mouth1.getX(), mouth1.getY());
    } else if (keyPressed) {
      image(mouth[a], mouth1.getX(), mouth1.getY());
    } else { //just show a still image of mouth if no keys are pressed.
      a = 0;
      image (mouth_ini, mouth1.getX(), mouth1.getY()); 
    }
    a = a+1;
    if (a>=2){
      a=0;
    }
  }
  
  //speed of mouth
  if (keyPressed && keyCode == RIGHT) {
    mouth1.setX(mouth1.getX() + 35); 
  }

  if (keyPressed && keyCode == LEFT) {
    mouth1.setX(mouth1.getX() - 35);
  }
  
  //if mouth hasn't jumped, make it jump, otherwise make it return to the ground
  if (keyPressed && keyCode == UP) {
      if (!inAir){
        mouth1.jumpUp();
      } 
  }
  
  if (inAir){
    mouth1.fallDown();
  }

  if (mouth1.getX() < 0){
     mouth1.setX(0);
  }

  //max distance to right and left of screen that mouth can move
  if (mouth1.getX() > 850){
    mouth1.setX( 850);
  }

  if (starY > 600){
    starX = int(random(50, 920));
    starY = 0;
    lives = lives - 1;
    sound_lives.rewind();
    sound_lives.play();
  }
  
  if (flameY > 600){
    flameX = int(random(50, 920));
    flameY = -500;
  }

  starred();
  flamed();  
}

//Collision detection - are the mouth and stars colliding?
void starred(){
  if (starY + 50 > mouth1.getY() && starX + -5 > mouth1.getX() && starX < mouth1.getX() + 145) {
    score = score + 1;
    starX = int(random(50, 920));
    starY = 0;
    sound_score.rewind();
    sound_score.play();
  }
}
  
//Collision detection - are the mouth and flames colliding? 
void flamed(){
  if (flameY + 50 > mouth1.getY() && flameX + -5 > mouth1.getX() && flameX < mouth1.getX() + 145) {
    lives = lives - 3;
    flameX = int(random(50, 920));
    flameY = -500;
  }
}

void keyPressed() {
  if (keyCode == DOWN) {
    gameover = false;
  }
}

//This is an object to set, track and update the position of the mouth
//It also has the ability to jump
class MouthPerson {    
  int pinkX; 
  int pinkY;
  //Constructor that sets the initial starting position
  MouthPerson(){
      pinkY = 450;
      pinkX = 100;
  }
  
  //These allow you to access or change (get or set) the X and Y values of the mouth
  int getX(){
    return pinkX;
  }
  
 int getY(){
    return pinkY;
  }
  
 void setX(int temp){
    pinkX = temp;
  }
  
 void setY(int temp){
    pinkY = temp;
  }
  
  //This moves Mouth up for a jump and sets its status as in the air
  void jumpUp(){
    pinkY = pinkY - 200;
    inAir = true;
    airCount = 0;
  }
  
  //This checks if mouth is in the air, waits for 3 draws and then moves it down
  void fallDown(){
    println(airCount);
    if(airCount >= 2){
      pinkY = pinkY + 200;
      inAir = false;
      airCount = 0;
    } else {
      airCount++;
    }
  }  
}
