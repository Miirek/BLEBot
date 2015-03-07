

#define echoPin 8 // Echo Pin
#define trigPin 10 // Trigger Pin
#define lightPin 9

void setup() {
  // put your setup code here, to run once:
  Serial.begin(9600); //open connection to bt/ble module
  botInit();  //setup the pins for the bot
  
}


void loop() {
  long dist = getdistance();
  bool wasDistance = false;
  if(dist > 0)
    while( dist < 30){
      wasDistance = true;
      botHardRight(255);
      delayMicroseconds(5000);
      digitalWrite(lightPin, HIGH);
      dist = getdistance();
      if (dist == 0) break;
    }
  
  Serial.println(dist);
  
  if (wasDistance) botStop();
  
  digitalWrite(lightPin, LOW);
  
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
    }
      Serial.write(input);
 
  }
  
  
}

 
void botForward(int botSpeed){
 digitalWrite(2, HIGH); 
 digitalWrite(5, HIGH);
 analogWrite(0, 255 - botSpeed);
 analogWrite(1, 255 - botSpeed);
}
 
void botReverse(int botSpeed){
 digitalWrite(2, LOW); 
 digitalWrite(5, LOW);
 analogWrite(0, botSpeed);
 analogWrite(1, botSpeed);
}
 
void botRight(int botSpeed){
 digitalWrite(2, LOW); 
 digitalWrite(5, HIGH);
 analogWrite(0, 0);
 analogWrite(1, 255 - botSpeed);
}
 
void botHardRight(int botSpeed){
 digitalWrite(2, LOW); 
 digitalWrite(5, HIGH);
 analogWrite(0, botSpeed);
 analogWrite(1, 255 - botSpeed);
}
 
void botLeft(int botSpeed){
 digitalWrite(2, HIGH); 
 digitalWrite(5, LOW);
 analogWrite(0, 255 - botSpeed);
 analogWrite(1, 0);
}
 
void botHardLeft(int botSpeed){
 digitalWrite(2, HIGH); 
 digitalWrite(5, LOW);
 analogWrite(0, 255 - botSpeed);
 analogWrite(1, botSpeed);
}
 
void botStop(){
 digitalWrite(2,LOW); 
 digitalWrite(5,LOW);
 analogWrite(0,0);
 analogWrite(1,0);
}
 
void botInit(){
 pinMode(0,OUTPUT);
 pinMode(1,OUTPUT);
 pinMode(2,OUTPUT);
 pinMode(5,OUTPUT);
 pinMode(trigPin, OUTPUT);
 pinMode(lightPin, OUTPUT);
 pinMode(echoPin, INPUT);
}

long getdistance ()
{
	
/* The following trigPin/echoPin cycle is used to determine the
 distance of the nearest object by bouncing soundwaves off of it. */ 	
 long d=0;
 
 digitalWrite(trigPin, LOW); 
 delayMicroseconds(2); 
 digitalWrite(trigPin, HIGH);
 delayMicroseconds(10); 

 digitalWrite(trigPin, LOW);
 d = pulseIn(echoPin, HIGH);

 //Calculate the distance (in cm) based on the speed of sound.
 d = d/58.2;
 return d;
}


