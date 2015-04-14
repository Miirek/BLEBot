#include <USI_TWI_Master.h>
#include <Wire.h>

#include <HMC5883L.h>
#include <NewPing.h>
#include <Messenger.h>

class MotorTracker {

  volatile long *accu;
  int interrupt;
public:
  MotorTracker (int numberOfHoles, volatile long *accuPtr, int interruptNumber){
    accu = accuPtr;
  }
  
  void Update (){
    
  }
};

class Compass {
  double heading;
  double correction;
  
  double declination;
  
  public:
  Compass (double corr){
    correction = corr;
  }
  
  void Update(){
  
  }
};


class ObstacleAvoidance{
  bool isObstacle;
  long distance;
  long maxDistance;
  
  public:
  ObstacleAvoidance (int echoPin, int trigPin, int maxDistance){
  }
  
  void Update(){
    
    
  }
};

// declarations

volatile long lAccu;
volatile long rAccu;

Compass comp(90);
MotorTracker lEng(20, &lAccu, 13);
MotorTracker rEng(20, &rAccu, 14);

ObstacleAvoidance radar(5,6,200);


void setup() {
  // put your setup code here, to run once:
  
  
}

void loop() {
  // put your main code here, to run repeatedly:
  comp.Update();
  lEng.Update();
  rEng.Update();
  radar.Update();
  
  
}
