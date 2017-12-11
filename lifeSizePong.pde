import org.openkinect.processing.*;

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

PVector location;
PVector velocity;
float bar1Y = 0;
float bar2Y = 0;
int barLength = 100;
int player1Score = 0;
int player2Score = 0;


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
  
  //ping pong stuff
  //create bars
  //fill(255);
  //rect(10, avgYR-20, 20, 40);
  //rect(670, avgYL-20, 20, 40);
  
    //score
  textSize(32);
  fill(255);
  text(player1Score, width/4, height/2); 
  text(player2Score, 3*width/4, height/2); 
  
  //draw bars
  fill(255);
  bar1Y = map(avgYR,50,300,0 ,height-barLength);
  bar2Y = map(avgYL,50,300, 0 ,height-barLength);
  rect(10,bar1Y,10,barLength);
  rect(width-20,bar2Y,10,barLength);
  // Add the current speed to the location.
  location.add(velocity);

  if ((location.x > width-20 && location.y >= bar2Y && location.y <= bar2Y+barLength) || (location.x < 20 && location.y >= bar1Y && location.y <= bar1Y+barLength)) {
    velocity.x = velocity.x * -1;
  }
  if ((location.y > height) || (location.y < 0)) {
    velocity.y = velocity.y * -1;
  }
  
  if(location.x < -10){
    println("player 1 lost");
    location.x  = width/2;
    location.y = height/2;
    player2Score++;
    velocity = new PVector(2,2.5);
    delay(1000);
  }
  else if(location.x > width+10){
    println("player 2 lost");
    location.x  = width/2;
    location.y = height/2;
    player1Score++;
    velocity = new PVector(2,2.7);
    delay(1000);
  }
  // Display circle at x location
  fill(175);
  ellipse(location.x,location.y,16,16);
  
  //increase vel over time
  //velocity.add(pow(-1,velocity.x>0?1:-1)*0.1, pow(-1,velocity.y>0?1:-1)*0.1);
  velocity.x += (velocity.x>0?0.003:-0.003);
  velocity.y += (velocity.y>0?0.005:-0.005);
  

}