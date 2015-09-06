
// Taken from http://kousaku-kousaku.blogspot.com/2008/08/arduino_24.html
#define xLow  14
#define xHigh 15
#define yLow  16
#define yHigh 17

void setup(){
  Serial.begin(9600);
}

void loop(){
  pinMode(xLow,OUTPUT);
  pinMode(xHigh,OUTPUT);
  digitalWrite(xLow,LOW);
  digitalWrite(xHigh,HIGH);

  digitalWrite(yLow,LOW);
  digitalWrite(yHigh,LOW);

  pinMode(yLow,INPUT);
  pinMode(yHigh,INPUT);
  delay(10);

  int x=analogRead(2);
  
  pinMode(yLow,OUTPUT);
  pinMode(yHigh,OUTPUT);
  digitalWrite(yLow,LOW);
  digitalWrite(yHigh,HIGH);

  digitalWrite(xLow,LOW);
  digitalWrite(xHigh,LOW);

  pinMode(xLow,INPUT);
  pinMode(xHigh,INPUT);
  delay(10);

  int y=analogRead(0);

    Serial.print(x,DEC);   
    Serial.print(",");     
    Serial.println(y,DEC); 

  delay(200);
}
