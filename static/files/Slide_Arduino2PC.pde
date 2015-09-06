#include <NewSoftSerial.h>
#include "ARCPO_Lib.h"

#define rxPin 3
#define txPin 2



//SoftwareSerial mySerial = SoftwareSerial(rxPin, txPin);
NewSoftSerial slide(rxPin,txPin);



void setup() {
  
  //mySerial.begin(9600);
  slide.begin(9600);
  Serial.begin(9600); // begin serial
}

void loop () {
  char myByte;
  
  //
  // RECEIVE FROM THE SLIDE : FORWARD 2 PC
  //
  if (slide.available() > 0)
  {
    myByte = (byte)slide.read();
    if (myByte != 0){
      ARCPOPacket vP;
      vP.ID = 1;
      vP.Type = 98;
      vP.SubType = 128;
      vP.Content [0] = myByte;
      vP.Content [1] = 0;
    
      writePacket (vP);
    }
    else {
      //Serial.println("read 0 :(");
    }
  }

 
  //
  // RECEIVE FROM THE PC : FORWARD 2 SLIDE
  //
  ARCPOPacket vPacket;
  vPacket = readPacket(vPacket);
  
  if (readPacketSuccess()){
    slide.print(vPacket.Type);
    slide.print(vPacket.SubType);
    slide.print(vPacket.Content);  
  
    //slide.print(vPacket.ID);
    //slide.print('b');
    //DEBUG_TRACE_ARCPOPACKET_TO_SERIAL(vPacket);
  }

  delay(10);
}
