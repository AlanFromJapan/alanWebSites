
#define BUFFLEN 8

byte mBuffer[BUFFLEN];

void setup()   {                
  for(int i =0; i < BUFFLEN; i++){
    mBuffer[i] = 0;
  }  


  for(int i =0; i < 16; i++){
    pinMode(i, OUTPUT);  
  }  

  for(int i =0; i < 16; i++){
    digitalWrite(i, HIGH);  
  }  

}

void randomOnOff(){
  int l,c;
  l = random(0,8);
  c = random(0,8);  
  byte b = mBuffer[c];
  b = b ^ _BV(l);
  mBuffer[c] = b;

}

int mPos = 0;
void scanLines(){
  int l,c;
  l = mPos / 8;
  c = mPos % 8;  
  byte b = mBuffer[c];
  b = b ^ _BV(l);
  mBuffer[c] = b;

  mPos = (mPos + 1) % 64;
}

void loop()                     
{
  //randomOnOff();
  scanLines();

  for (int c = 0; c < BUFFLEN; c++){
    PORTD = mBuffer[c];
    PORTB = ~_BV(c);
    PORTC = (c >= 6 ? ~_BV(c - 6) : 0xFF);
    delay(1);
    PORTD = 0;
    PORTB = 0xFF;
    PORTC = 0xFF;
  }

}






