import org.openkinect.processing.*;
import processing.sound.*;


// Kinect Library object
Kinect2 kinect2;

float minThresh = 500;
float maxThresh = 1400;
PImage img;
float prevAvgXL = 0;
float prevAvgYL = 0;
float prevAvgXR = 0;
float prevAvgYR = 0;
boolean player1Circle = false;
boolean player2Circle = false;

//pong
PVector location;
PVector velocity;
float bar1Y = 0;
float bar2Y = 0;
int barLength = 100;
int barWidth = 10;
int player1Score = 0;
int player2Score = 0;
boolean beginGame = false;
int maxScore = 100;
float[][] ballTrail = new float[5][2];
int ballCounter = 0;
int[] scoreUpdate = new int[]{0,0};
color bar1 = 0;
color bar2 = 0;



//Sound
SoundFile file;
Amplitude amp;
AudioIn in;

//time
int time;
int wait = 10000;

void setup() {
  size(512, 424);
  kinect2 = new Kinect2(this);
  kinect2.initDepth();
  kinect2.initDevice();
  img = createImage(kinect2.depthWidth, kinect2.depthHeight, RGB);
  println(kinect2.depthHeight);
  //img = createImage(w, kinect2.depthHeight, RGB);
  location = new PVector(100,100);
  velocity = new PVector(3,3.5);
  
  //set the ball trail to center position
  for(int i = 0; i<5; i++){
    ballTrail[i] = new float[]{width/2, height/2};
  }
  time = millis();//store the current time
  
  //sound    
  //file = new SoundFile(this, "best.mp3");
  //file.play();
  // Create an Input stream which is routed into the Amplitude analyzer
  amp = new Amplitude(this);
  in = new AudioIn(this, 0);
  in.start();
  amp.input(in);
}

void keyPressed(){
  beginGame = true;
}

void draw() {
  background(0);

  img.loadPixels();

  //minThresh = map(mouseX, 0, width, 0, 4500);
  //maxThresh = map(mouseY, 0, height, 0, 4500);


  // Get the raw depth as array of integers
  int[] depth = kinect2.getRawDepth();

  float sumXL = 0;
  float sumYL = 0;
  float totalPixelsL = 0;
  float sumXR = 0;
  float sumYR = 0;
  float totalPixelsR = 0;
  player2Circle = false;
  player1Circle = false;
  
  for (int x = 0; x < kinect2.depthWidth; x++) {
    for (int y = 0; y < kinect2.depthHeight; y++) {
      int offset = x + y * kinect2.depthWidth;
      int d = depth[offset];

      if (d > minThresh && d < maxThresh && x > 275) {
        
        if (d < maxThresh-100) {
          img.pixels[offset] = color(255, 0, 150, 100);
          player2Circle = true;
          sumXL += x;
          sumYL += y;
          totalPixelsL++;
        }
          
      } 
      else if (d > minThresh && d < maxThresh && x < 275) {
        
        if (d < maxThresh-100) {
          img.pixels[offset] = color(150, 0, 200, 100);
          player1Circle = true;
          sumXR += x;
          sumYR += y;
          totalPixelsR++;
        }
          
      } 
      else {
        img.pixels[offset] = color(0);
      }
    }
  }

  img.updatePixels();
  //img.resize(width, height);
  image(img, 0, 0);

  float avgXL = sumXL / totalPixelsL;
  float avgYL = sumYL / totalPixelsL;
  float avgXR = sumXR / totalPixelsR;
  float avgYR = sumYR / totalPixelsR;
  //print(sumXL+" ");
  //println(avgXL);
  if(totalPixelsL < 500)
    avgYL = prevAvgYL;
  else
    prevAvgYL = avgYL;
  if(totalPixelsR < 500)
    avgYR = prevAvgYR;
  else
    prevAvgYR = avgYR;  
  //if(sumXL <200 || sumXR<200 ){
  //   //println(prevAvgXL);
  //   avgYL = 250; 
  //   avgYR = 250; 
  //}
  //else{
  //   println(prevAvgXL);
  //   prevAvgXL = avgXL; 
  //   prevAvgXR = avgXR; 
  //   prevAvgYL = avgYL; 
  //   prevAvgYR = avgYR; 
  //}
  
  if(player1Circle)
    fill(150, 0, 255);
  else
    noFill();
  ellipse(avgXL, avgYL, 64, 64);
  
  if(player2Circle)
     fill(255, 0, 150);
  else
    noFill();
  ellipse(avgXR, avgYR, 64, 64);


  //for (int i = 0; i < 10; i++) {
  //  ps.addParticle(avgX, avgY);
  //}
  //ps.run();

  //fill(255);
  //textSize(32);
  //text(minThresh + " " + maxThresh, 10, 64);
  
  if(beginGame){
    //ping pong stuff
    //create bars
    //fill(255);
    //rect(10, avgYR-20, 20, 40);
    //rect(670, avgYL-20, 20, 40);
    
    //play music and visual
    audioVisual();
    
   
    //score
    textSize(32);
    fill(255);
    text(player1Score, width/4, height/2); 
    text(player2Score, 3*width/4, height/2); 
    

    // Add the current speed to the location.
    location.add(velocity);
  
    if ((location.x > width-30 && location.y >= bar2Y-10 && location.y <= bar2Y+barLength+10) || (location.x < 30 && location.y >= bar1Y-10 && location.y <= bar1Y+barLength+10)) {
      velocity.x = velocity.x  * -1;
      //location.x+= velocity.x>0?3:-3;
     
      if(location.x < width/2){
        println(location.x);
        bar1 = color(255, 204, 0);
        bar2 = color(255);
      }
      else{
        bar2 = color(255, 204, 0);
        bar1 = color(255);
      }   
    }
    else{
      bar1 = color(255);
      bar2 = color(255);
    }
    if ((location.y > height) || (location.y < 0)) {
      velocity.y = velocity.y * -1;
      sparks(location.x, location.y);
    }
    
    //draw bars
    noStroke();
    fill(bar1);
    //bar1Y = map(avgYR,50,300,0 ,height-barLength);
    //bar2Y = map(avgYL,50,300, 0 ,height-barLength);
    bar1Y = map(mouseY,50,300,0 ,height-barLength);
    bar2Y = map(mouseY,50,300, 0 ,height-barLength);
    rect(0,bar1Y,barWidth,barLength);
    fill(bar2);
    rect(width-barWidth,bar2Y,barWidth,barLength);
    
    //score
    if(location.x < -10){
      println("player 1 lost");
      location.x  = width/2;
      location.y = height/2;
      player2Score++;
      scoreUpdate[1] = 200;
      velocity = new PVector(2,random(1)>0.5?2.5:-2.5);  // go either left or right
      //delay(1000);
    }
    else if(location.x > width+10){
      println("player 2 lost");
      location.x  = width/2;
      location.y = height/2;
      player1Score++;
      scoreUpdate[0] = 200;
      velocity = new PVector(-2,random(1)>0.5?2.7:-2.7);
      //delay(1000);
    }
    scoreEffect();
    // Display circle at x location
    fill(175);
    ellipse(location.x,location.y,16,16);
    
    //update and show trail
    ballTrail[ballCounter] = new float[]{location.x, location.y};
    if(ballCounter < 4)
      ballCounter++;
    else
      ballCounter = 0;
    
    noStroke();
    int brightness = 150;
    for(int i = 0; i < 5; i++){
       fill(175,brightness);
       brightness-=50;
       ellipse(ballTrail[i][0], ballTrail[i][1], 16,16);
    }
    
    //increase vel over time
    //velocity.add(pow(-1,velocity.x>0?1:-1)*0.1, pow(-1,velocity.y>0?1:-1)*0.1);
    velocity.x += (velocity.x>0?0.002:-0.002);
    velocity.y += (velocity.y>0?0.004:-0.004);
    
    
    if(millis() - time >= wait){
      time = millis();//also update the stored time
      wait+= random(-2000, 2000);
      if(location.x > width/4 && location.x < 3*width/4){
        velocity.x = velocity.x  * -1;
        velocity.y = velocity.y  * -1;
      }
    }

  }
  if(player1Score == maxScore)
    winner(1);
  else if (player2Score == maxScore)
    winner(2);

}

void winner(int n){
  text("Player "+n+" wins", width/4, height/2); 
  beginGame = false;
  shine(n);
}

void shine(int n){
  int x = 0;
  if(n==2){
      x = width/2;
  }
  stroke(255);
  strokeWeight(5);
  noFill();
  rect(x,0,width/2-5, height-5);
}

void audioVisual(){
  //background(255,10);
  //println(amp.analyze());
  //draw circles
  fill(255);
  stroke(255);
  pushMatrix();
    translate(width/2, height/2);
    rotate(random(10));
    int step = 100;  //increase radius
    for(int i=0; i<amp.analyze()*10000; i++){
      rotate(0.1);
      //ellipse(random(width/4, 3*width/4), random(height/4, 3*height/4), 10, 10);
      //ellipse(0, random(step), 7, 7);
      float r = random(20, step);
      line(0,r-random(50),0,r); //draw lines around
      if(i%100 == 0)
        step+=60;
        
      //extra for loud music
      if(amp.analyze()*100 > 1){
          if(step > 200)
            fill(random(200),150,150,random(150,255));
          else  
            fill(220,220+random(25),220);
            
          noStroke();
          ellipse(0, random(step), 4, 4);
      }
    }
  popMatrix();
}

void scoreEffect(){
  //println(scoreUpdate[0]);
  //println(scoreUpdate[1]);
  fill(255,150);
  if(scoreUpdate[0] > 0){
    textSize(200 - scoreUpdate[0]);
    text(player1Score, width/4 - 10 - scoreUpdate[0]/25 , height/2 + 10 - scoreUpdate[0]/25);
    scoreUpdate[0]-= 5;
  }
  if(scoreUpdate[1] > 0){
    textSize(200 - scoreUpdate[1]);
    text(player2Score, 3*width/4 - 10 - scoreUpdate[1]/25 , height/2 + 10 - scoreUpdate[1]/25);
    scoreUpdate[1]-= 5;
  }
}

void sparks(float x, float y){
   pushMatrix();
     translate(x,y);
     fill(255, 204, 0);
     beginShape();
       vertex(0,0);
       for(int i = 0; i< 20; i++){
         //line(0,0,0,random(70));
         vertex(random(-20,20),random(-50,50));
         rotate(0.3);
       }
       vertex(0,0);
     endShape();
   popMatrix();
}