
/*

http://www.bajdi.com

 L9110 motor driver controlling 2 small DC motors 
 */
/*
const int AIA = 9;  // (pwm) pin 9 connected to pin A-IA 
const int AIB = 5;  // (pwm) pin 5 connected to pin A-IB 
const int BIA = 10; // (pwm) pin 10 connected to pin B-IA  
const int BIB = 6;  // (pwm) pin 6 connected to pin B-IB 
*/
const int AIA = 0;  // (pwm) pin 9 connected to pin A-IA 
const int AIB = 1;  // (pwm) pin 5 connected to pin A-IB 
const int BIA = 2; // (pwm) pin 10 connected to pin B-IA  
const int BIB = 5;  // (pwm) pin 6 connected to pin B-IB 

const int lwCounterPIN = 10;
const int rwCounterPIN = 11;

const int statusInfoInterval = 2000; // in milliseconds
const int numberOfTicks = 12; // ticks per rotation


volatile long leftWheelCounter;
volatile long rightWheelCounter;

volatile long leftWheelInterval;
volatile long rightWheelInterval;

volatile long leftWheelLastMillis;
volatile long rightWheelLastMillis;

const byte dirForward = 0;
const byte dirBackward = 1;

typedef String (*funcptr)();

class sInfo{
  public:
   inline virtual void statusInfo(){
   }
};

class Telemetry {
    long reportIntervalMS;
    long lastUpdate;
    sInfo *infos[10]; 
    int ptrCnt;
  public:
      Telemetry(long interval){
        this->reportIntervalMS = interval;
        this->lastUpdate = 0;
        this->ptrCnt = 0;   
      }
      
      void update(){
        
        long msNow = millis();
        if((msNow - this->lastUpdate) > this->reportIntervalMS) {
            
          for (byte i=0; i<this->ptrCnt; i++){
            sInfo *fce = this->infos[i];
            fce->statusInfo();
          }
       
          this->lastUpdate = millis();
        }
      }
      
      void registerInfo(sInfo *reporter){
          if(this->ptrCnt < 10){
             this->infos[this->ptrCnt] = reporter;
             this->ptrCnt ++;  
        }
          
      }
};

class Engine : public sInfo {
  
  byte xIA;
  byte xIB;
  
  byte wheelSpeed;
  
  volatile long * rpmTotalTicks;
  long rpmTriggerTicks;
  
  String name;
  
  long timerStart;
  long timerStop;
  
  int wheelRPM;
    
  byte direction;
  
  public:
     Engine(byte xia, byte xib, String name){
       this->xIA = xia;
       this->xIB = xib;
       this->wheelSpeed = 0;
       this->direction = dirForward;
       this->name = name;  
 } 
     
     void start(){
        pinMode(this->xIA, OUTPUT); // set pins to output
        pinMode(this->xIB, OUTPUT);
     }
     
     Engine* setDirection(byte dir){
       this->direction = dir;
       return this;
     }
     
     Engine * setSpeed(byte speed){
       this->wheelSpeed = speed;
       return this;  
     }
     
     Engine * setRuntime(long msToRun){
       this->timerStop = millis() + msToRun;  
     }
     
     Engine * setRunTicks(long ticksToStop){
       if(ticksToStop == 0){
         this->rpmTriggerTicks = 0;
         return this;
       }
       this->rpmTriggerTicks = *this->rpmTotalTicks + ticksToStop;
       return this;
     }
     
     Engine * forward(){
        analogWrite(this->xIA, 0);
        analogWrite(this->xIB, wheelSpeed);
     }
     
     Engine * backward(){
        analogWrite(this->xIA, wheelSpeed);
        analogWrite(this->xIB, 0);
     }
     
     void stop(){
        analogWrite(this->xIA, 0);
        analogWrite(this->xIB, 0);
        this->wheelSpeed = 0;
     }
     
     void attachCounter(volatile long *cnt){
         this->rpmTotalTicks = cnt;
     }
     
     void update(){
       if(this->wheelSpeed == 0){
           this->stop();
           return;
       }
       
       if(this->direction == dirForward)
         this->forward();
       else
         this->backward();
      
       // tikker limit
       if(this->rpmTriggerTicks != 0){ // pocet tiku
           if(this->rpmTriggerTicks < *this->rpmTotalTicks){
             this->stop();
             this->rpmTriggerTicks = 0;
           }
       } 
       
       // timer limit
       if(this->timerStop != 0){
         long timerMillis = millis();
         if(this->timerStop <= timerMillis){
           this->stop();
           this->timerStop = 0;
         }
       }
     }//update
     
     
     virtual void statusInfo(){
        Serial.print("$ENGINE:");
        Serial.print("N:");Serial.print(this->name.c_str());Serial.print(";");
        Serial.print("S:");Serial.print(this->wheelSpeed);Serial.print(";");
        Serial.print("T:");Serial.print((long)this->rpmTotalTicks);Serial.print(";");
        Serial.println("");
       /*
        ; nfo.concat(";");
        nfo += "S:"; nfo += this->wheelSpeed; nfo += ';';
        nfo += "T:"; nfo += (long)this->rpmTotalTicks; nfo += ';';/**/
        //Serial.println(xstr);
     }

};

byte speed = 255;  // change this (0-255) to control the speed of the motors 

Engine *leftMotor;
Engine *rightMotor;

Telemetry *tlmtry;

long statusStringMillis;


void setup() {
  leftWheelCounter = 0;
  rightWheelCounter = 0;
  
  leftWheelLastMillis = 0;
  rightWheelLastMillis = 0;
  
  leftWheelInterval = 0;
  rightWheelInterval = 0;
  
  attachInterrupt(lwCounterPIN,leftWheelISR,CHANGE);
  attachInterrupt(rwCounterPIN,rightWheelISR,CHANGE);
  
  Serial.begin(9600); //open connection to bt/ble module
  Serial.println("#RESTART");
  leftMotor = new Engine(BIA,BIB,"LW");
  rightMotor = new Engine(AIA,AIB,"RW");
  tlmtry = new Telemetry(200);
  
  tlmtry->registerInfo(leftMotor);
  tlmtry->registerInfo(rightMotor);
  
  leftMotor->attachCounter(&leftWheelCounter);
  leftMotor->attachCounter(&rightWheelCounter);
   
  leftMotor ->start();
  rightMotor->start();
  
  leftMotor->setSpeed(255)->setRuntime(300);
  rightMotor->setSpeed(255)->setDirection(dirBackward)->setRuntime(300); 

 // delay(5);
 // leftMotor->
}

void loop() {
    if(Serial.available()){
    char input = Serial.read();
    //route based on input

    if(input == 'f'){
      botForward(255);
    }
    else if(input == 'b'){
      botReverse(255);
    }
    else if(input == 'r'){
      botRight(200);
    }
    else if(input == 'l'){
      botLeft(200);
    }
    else if(input == 's'){
      botStop();
    }
   else if(input == 'x'){
      botHardRight(255);
    }
   else if(input == 'y'){
      botHardLeft(255);
    }else{
      botStop();
    }
      Serial.write(input);
 
  }
 
  leftMotor->update();
  rightMotor->update();
  tlmtry->update();
}

// ISR -------
void leftWheelISR(){
  leftWheelCounter ++;
  leftWheelInterval = millis() - leftWheelLastMillis;
  leftWheelLastMillis = millis();
}

void rightWheelISR(){
  rightWheelCounter ++;
  rightWheelInterval = millis() - rightWheelLastMillis;
  rightWheelLastMillis = millis();
}
// commands  ----------------------

void botForward(int botSpeed){
  leftMotor->setSpeed(botSpeed)->setDirection(dirForward);
  rightMotor->setSpeed(botSpeed)->setDirection(dirForward);
}
 
void botReverse(int botSpeed){
  leftMotor->setSpeed(botSpeed)->setDirection(dirBackward);
  rightMotor->setSpeed(botSpeed)->setDirection(dirBackward);
}
 
void botRight(int botSpeed){
  rightMotor->stop();
  leftMotor->setSpeed(botSpeed)->setDirection(dirForward);
}
 
void botHardRight(int botSpeed){
  rightMotor->setSpeed(botSpeed)->setDirection(dirBackward);
  leftMotor->setSpeed(botSpeed)->setDirection(dirForward);
}
 
void botLeft(int botSpeed){
  leftMotor->stop();
  rightMotor->setSpeed(botSpeed)->setDirection(dirForward);
}
 
void botHardLeft(int botSpeed){
  rightMotor->setSpeed(botSpeed)->setDirection(dirForward);
  leftMotor->setSpeed(botSpeed)->setDirection(dirBackward);
}
 
void botStop(){
  leftMotor->stop();
  rightMotor->stop();
}



