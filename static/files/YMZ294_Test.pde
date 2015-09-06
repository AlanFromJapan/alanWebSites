//YMZ294
//D0-D7 = 0-7pin
int WR = 8;
int CS = 9;
int A0 = 10;

int tp[] = {//MIDI note number
  15289, 14431, 13621, 12856, 12135, 11454, 10811, 10204,//0-7
  9631, 9091, 8581, 8099, 7645, 7215, 6810, 6428,//8-15
  6067, 5727, 5405, 5102, 4816, 4545, 4290, 4050,//16-23
  3822, 3608, 3405, 3214, 3034, 2863, 2703, 2551,//24-31
  2408, 2273, 2145, 2025, 1911, 1804, 1703, 1607,//32-39
  1517, 1432, 1351, 1276, 1204, 1136, 1073, 1012,//40-47
  956, 902, 851, 804, 758, 716, 676, 638,//48-55
  602, 568, 536, 506, 478, 451, 426, 402,//56-63
  379, 358, 338, 319, 301, 284, 268, 253,//64-71
  239, 225, 213, 201, 190, 179, 169, 159,//72-79
  150, 142, 134, 127, 119, 113, 106, 100,//80-87
  95, 89, 84, 80, 75, 71, 67, 63,//88-95
  60, 56, 53, 50, 47, 45, 42, 40,//96-103
  38, 36, 34, 32, 30, 28, 27, 25,//104-111
  24, 22, 21, 20, 19, 18, 17, 16,//112-119
  15, 14, 13, 13, 12, 11, 11, 10,//120-127
  0//off
};

void setup(){
  //init pins
  for(int i=0; i < 8;i++){
    pinMode(i, OUTPUT);
  }
  pinMode(WR, OUTPUT);
  pinMode(CS, OUTPUT);
  pinMode(A0, OUTPUT);
  
  write_data(0x06, 0x00);
  write_data(0x07, 0x3e);
  write_data(0x08, 0x0f);
}

void set_chA(int i)
{
  write_data(0x00, tp[i]&0xff);
  write_data(0x01, (tp[i] >> 8)&0x0f);
}

void write_data(unsigned char address, unsigned char data)
{
  //write address
  digitalWrite(WR, LOW);
  digitalWrite(CS, LOW);
  digitalWrite(A0, LOW);
  
  for(int i=0; i < 8; i++){
    digitalWrite(i, (address >> i)&0x01);
  }
  
  digitalWrite(WR, HIGH);
  digitalWrite(CS, HIGH);
  //write data
  digitalWrite(WR, LOW);
  digitalWrite(CS, LOW);
  digitalWrite(A0, HIGH);
  
  for(int i=0; i < 8; i++){
    digitalWrite(i, (data >> i)&0x01);
  }
  
  digitalWrite(WR, HIGH);
  digitalWrite(CS, HIGH);
}

void loop(){
  set_chA(60);
  delay(500);
  set_chA(62);
  delay(500);
  set_chA(64);
  delay(500);
  set_chA(65);
  delay(500);
  set_chA(64);
  delay(500);
  set_chA(62);
  delay(500);
  set_chA(60);
  delay(500);
  set_chA(128);
  delay(500);
  
  set_chA(64);
  delay(500);
  set_chA(65);
  delay(500);
  set_chA(67);
  delay(500);
  set_chA(69);
  delay(500);
  set_chA(67);
  delay(500);
  set_chA(65);
  delay(500);
  set_chA(64);
  delay(500);
  set_chA(128);
  delay(500);
  
  set_chA(60);
  delay(500);
  set_chA(128);
  delay(500);
  set_chA(60);
  delay(500);
  set_chA(128);
  delay(500);
  set_chA(60);
  delay(500);
  set_chA(128);
  delay(500);
  set_chA(60);
  delay(500);
  set_chA(128);
  delay(500);
  
  set_chA(60);
  delay(128);
  set_chA(128);
  delay(128);
  set_chA(60);
  delay(128);
  set_chA(128);
  delay(128);
  set_chA(62);
  delay(128);
  set_chA(128);
  delay(128);
  set_chA(62);
  delay(128);
  set_chA(128);
  delay(128);
  set_chA(64);
  delay(128);
  set_chA(128);
  delay(128);
  set_chA(64);
  delay(128);
  set_chA(128);
  delay(128);
  set_chA(65);
  delay(128);
  set_chA(128);
  delay(128);
  set_chA(65);
  delay(128);
  set_chA(128);
  delay(128);
  set_chA(64);
  delay(250);
  set_chA(128);
  delay(250);
  set_chA(62);
  delay(250);
  set_chA(128);
  delay(250);
  set_chA(60);
  delay(250);
  set_chA(128);
  delay(1000);
}
