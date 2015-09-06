//ArdTimeLapse
// AlanFromJapan http://kalshagar.wikispaces.com/ardTimeLapse

#define LEDON 11
#define LEDSHOOT 12
#define PINSHOOT 13
#define PINDURATION 0
#define PINEXPOLEN 1

void setup()   {           
    //factor settings is to divide internal clock 8MHz by 8.
    //don't, and just run at 8 MHz (set the clock divider to 1 so no effect)
    CLKPR = (1<<CLKPCE);
    CLKPR = 0; // Divide by 1 
    
  // initialize the digital pin as an output:
  pinMode(LEDON, OUTPUT);     
  pinMode(LEDSHOOT, OUTPUT);     
  pinMode(PINSHOOT, OUTPUT);     
  
  //turn on light on
  digitalWrite(LEDON, HIGH);
  digitalWrite(LEDSHOOT, LOW);
  digitalWrite(PINSHOOT, LOW);
}

unsigned long mDuration = 0;
unsigned long mExpolen = 0;
unsigned long mLastShotTime = 0;

void loop()                     
{
  //duration are divided by 2, since all the timing is compiled for a 16MHz running Arduino but runs on a on-chip 8MHz oscillator
  //DURATION: max = 1024 = 1 sec => x900 = max is 15 min
  mDuration = 900 * analogRead(PINDURATION) /2;
  //EXPO: max = 1024 = 1 sec => x30 = max is 30 sec
  mExpolen = 30 * analogRead(PINEXPOLEN) /2; 
  
  if (mExpolen > mDuration){
    mDuration = mExpolen;
  }
  
  unsigned long vTime = millis();

  //rollover
  if (vTime < mLastShotTime){
    mLastShotTime = 0;
  }
    
  //shoot ?
  if (vTime - mLastShotTime > mDuration){
    digitalWrite(LEDSHOOT, HIGH);
    digitalWrite(PINSHOOT, HIGH);

    mLastShotTime = millis();
    while(millis() - vTime < mExpolen){ delay(10); }

    digitalWrite(LEDSHOOT, LOW);
    digitalWrite(PINSHOOT, LOW);
    

  }
  
  delay(50);
}
