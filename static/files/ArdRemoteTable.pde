#include <CapSense.h>
#include <IRremoteInt.h>
#include <IRremote.h>

unsigned int CHUP[] = {
  3400,1650,450,400,450,1200,450,400,450,1200,500,350,450,1250,450,350,500,1200,450,400,400,1250,450,400,400,1250,450,1250,450,350,500,1200,450,350,450,1250,400,1250,450,1250,400,1250,450,400,450,350,450,400,500,1200,400,450,450,1200,450,400,400,450,450,1200,450,400,400,450,450,350,500,1200,450,400,450,350,500,350,450,1250,450,350,450,400,450,400,450,1250,450,350,450,400,450,400,450,400,450,1200,450,400,450,1200,450};
unsigned int CHDOWN[] = {
  3400,1650,450,400,450,1200,450,400,450,1250,400,400,450,1250,400,450,450,1200,450,400,400,1250,450,400,450,1200,450,1250,450,350,500,1200,400,450,400,1250,450,1200,450,1250,400,1250,450,400,450,400,400,450,450,1200,450,400,450,1200,450,400,450,400,450,1200,450,400,450,400,400,450,450,350,450,1250,400,450,400,400,500,1200,400,450,450,350,500,350,450,1250,450,350,450,400,450,400,450,1200,450,400,450,400,450,1250,450};
unsigned int VOLUP[] = {
  3400,1700,400,400,450,1250,450,400,400,1250,450,400,450,1200,450,400,450,1200,450,400,450,1200,450,400,450,1250,400,1250,450,400,400,1250,450,400,450,1200,450,1250,450,1200,450,1200,500,350,450,400,450,400,450,1200,450,400,450,1200,450,400,450,400,450,1200,450,400,450,400,450,400,450,400,450,350,450,1250,450,400,400,1250,450,400,450,400,400,450,400,1250,450,400,450,350,450,400,500,1200,450,1200,450,1250,450,1200,400};
unsigned int VOLDOWN[] = {
  3400,1650,450,400,450,1250,400,400,450,1250,400,400,450,1250,400,450,400,1250,450,400,400,1250,450,400,450,1200,450,1250,400,450,400,1250,450,400,400,1250,450,1200,450,1250,400,1250,450,400,450,400,400,450,400,1250,450,400,400,1250,450,400,450,400,450,1200,450,400,450,400,400,450,450,1200,450,400,400,1250,450,400,450,1200,500,350,450,400,450,400,400,1250,450,400,450,400,450,400,400,450,400,1250,400,1250,450,1250,450};
unsigned int POWER[] = {
  3350,1700,400,450,400,1250,400,450,400,1250,450,400,400,1250,450,400,450,1200,450,400,450,1250,400,400,450,1250,400,1250,450,400,400,1250,450,400,450,1200,450,1250,400,1250,450,1250,400,400,450,400,450,400,450,1200,450,400,450,1250,400,400,450,400,450,1250,400,400,450,400,450,400,450,400,400,1250,450,1250,400,400,450,1250,400,450,400,400,450,400,450,1250,400,450,400,400,450,400,450,1250,400,400,450,1250,400,1250,450};  
unsigned int CHANGEINPUT[] = {
  3350,1700,450,400,400,1250,450,400,450,1200,450,400,450,1200,450,400,450,1250,400,400,450,1250,400,450,400,1250,450,1200,450,400,450,1250,400,400,450,1250,400,1250,450,1250,400,1250,400,450,400,400,450,400,450,1250,400,400,450,1250,400,450,400,400,450,1250,400,450,400,450,400,400,450,1250,400,1250,450,400,400,450,400,1250,450,400,400,450,400,450,400,1250,400,450,400,450,400,400,450,400,450,400,450,400,400,1250,450};

#define TOUCH_THRESHOLD 200

//CapSense   cs_Touch1 = CapSense(4,2);        // 10M resistor between pins 4 & 2, pin 2 is sensor pin, add wire, foil
//CapSense   cs_Touch2 = CapSense(4,5);        // 10M resistor between pins 4 & 6, pin 6 is sensor pin, add wire, foil
//CapSense   cs_Touch3 = CapSense(4,6);        // 10M resistor between pins 4 & 8, pin 8 is sensor pin, add wire, foil

#define TOUCHSENSORS 6

CapSense mSensors[TOUCHSENSORS] = {
  CapSense(4,0),
  CapSense(4,1),
  CapSense(4,2),
  CapSense(4,6),
  CapSense(4,7),
  CapSense(4,8)
  };

  IRsend irsend;

//for the test
void Blink (int pCount){
  for (int i = 0; i < pCount; i++){
    digitalWrite(13, HIGH);   // set the LED on
    delay(50);                  // wait for a second
    digitalWrite(13, LOW);    // set the LED off

    if(i < pCount-1){
      delay(200);
    }
  }
}
//for the test
void Blink2 (int pCount){
  for (int i = 0; i < pCount; i++){
    digitalWrite(12, HIGH);   // set the LED on
    delay(30);                  // wait for a second
    digitalWrite(12, LOW);    // set the LED off

    if(i < pCount-1){
      delay(30);
    }
  }
}

void setup()                    
{
  //CLKPR = (1<<CLKPCE);
  //CLKPR = 3;  


  for(int i = 0; i < TOUCHSENSORS; i++){
    mSensors[i].set_CS_AutocaL_Millis(5000);     //recalibrate every 5 sec
  }


  //cs_Touch1.set_CS_AutocaL_Millis(5000);     //recalibrate every 5 sec
  //cs_Touch1.set_CS_AutocaL_Millis(0xFFFFFFFF);     // turn off autocalibrate on channel 1 - just as an example
  //  cs_Touch2.set_CS_AutocaL_Millis(0xFFFFFFFF);     // turn off autocalibrate on channel 1 - just as an example
  //  cs_Touch3.set_CS_AutocaL_Millis(0xFFFFFFFF);     // turn off autocalibrate on channel 1 - just as an example
  //Serial.begin(115200);

  pinMode(13, OUTPUT);   
  pinMode(12, OUTPUT);  
}

void SendIRCommand (int pCommandID){
  switch(pCommandID){
  case 0:
    irsend.sendRaw(VOLUP, sizeof(VOLUP)/sizeof(unsigned int), 38);
    break;    
  case 1:
    irsend.sendRaw(VOLDOWN, sizeof(VOLDOWN)/sizeof(unsigned int), 38);
    break;    
  case 2:
    irsend.sendRaw(CHUP, sizeof(CHUP)/sizeof(unsigned int), 38);
    break;    
  case 3:
    irsend.sendRaw(CHDOWN, sizeof(CHDOWN)/sizeof(unsigned int), 38);
    break;    
  case 4:
    irsend.sendRaw(POWER, sizeof(POWER)/sizeof(unsigned int), 38);
    break;    
  case 5:
    irsend.sendRaw(CHANGEINPUT, sizeof(CHANGEINPUT)/sizeof(unsigned int), 38);
    break;    
  }

}

void loop()                    
{
  boolean vTouched =false;
  Blink(1);


  for(int i = 0; !vTouched && i < TOUCHSENSORS; i++){
    if (mSensors[i].capSense(30) > TOUCH_THRESHOLD) {
      SendIRCommand(i);

      Blink2(i+1);
      vTouched=true;
    }
    delay(15); //avoid parasites ?
  }

  /*
  if (cs_Touch1.capSense(30) > TOUCH_THRESHOLD) {
   //Serial.println("Touched");
   Blink2(4);
   irsend.sendRaw(POWER, sizeof(POWER)/sizeof(unsigned int), 38);
   vTouched=true;
   }
   */
  /*
   if (cs_Touch3.capSense(30) > TOUCH_THRESHOLD) {
   Serial.println("Touched 3");
   irsend.sendRaw(CHANGEINPUT, sizeof(CHANGEINPUT)/sizeof(unsigned int), 38);
   vTouched=true;
   }
   */

  if (vTouched){
    delay(300);                             // avoid multi touch 
  }
  else {
    delay(100);                             // arbitrary delay to check frequency
  }
}














