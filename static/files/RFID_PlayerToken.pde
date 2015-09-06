#include <NewSoftSerial.h>
#include "ARCPO_Lib.h"

#define PACKET_TYPE_EXTENDED '@'
#define PACKET_SUBTYPE_RFID 'R'

#define LED_PIN 12

#define rxPin 2
#define txPin 3
NewSoftSerial mySerial(2,3);


void setup() {
  pinMode(LED_PIN, OUTPUT);      // sets the digital pin as output

  //serial to PC
  Serial.begin(9600);

  //soft serial to RFID reader
  // set the data rate for the SoftwareSerial port
  mySerial.begin(9600);

  //blink blink hello I'm online
  for (int i =0; i < 5; i++){
    digitalWrite(LED_PIN, HIGH);   // sets the LED on
    delay(100);                  // waits 
    digitalWrite(LED_PIN, LOW);    // sets the LED off
    delay(50);                  // waits 
  }
}

void loop() {
  if (mySerial.available()) {
    char vCode[14];
    for(int i= 0; i < 14; i++){
      //read() is not blocking with that library, so wait until something to read
      while (!mySerial.available()) ;
      int someChar = mySerial.read();

      vCode[i] = (char)someChar;
    }

    if(vCode[0] == 2 && vCode[13] == 3){
      //looks good, send to mothership
      /*
      for(int i= 1; i < 12; i++){
       Serial.print(vCode[i]);
       }
       Serial.println("");
       */
      ARCPOPacket vP;
      vP.ID = 1;
      vP.Type = PACKET_TYPE_EXTENDED; //extended command
      vP.SubType = PACKET_SUBTYPE_RFID;
      //copy content (minus header and trailer) and add the final \0
      strncpy(vP.Content, vCode +1, 12);
      vP.Content [12] = 0;

      writePacket (vP);

      //sent, now show a long blink
      digitalWrite(LED_PIN, HIGH);   // sets the LED on
      delay(800);                  // waits 
      digitalWrite(LED_PIN, LOW);    // sets the LED off
    }
    else {
      //Read crap :(
      //ignore for now (blink blink)
      for (int i =0; i < 3; i++){
        digitalWrite(LED_PIN, HIGH);   // sets the LED on
        delay(100);                  // waits 
        digitalWrite(LED_PIN, LOW);    // sets the LED off
        delay(50);                  // waits 
      }
    }
  }

}



