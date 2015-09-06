// includes
#include <avr/io.h>
#include <util/delay.h>
#include <avr/interrupt.h>

#define BUFFLEN 8

unsigned char mBuffer[BUFFLEN];

void digitalWrite(unsigned char pPin, unsigned char pValue){
	if (pValue == 1) {	
		if (pPin < 8){
			PORTB = PORTB ^ (1 << pPin);
		}
		else
		if (pPin < 16){
			PORTC = PORTC ^ (1 << pPin);
		}
	}
	else {
		if (pPin < 8){
			PORTB = PORTB & ~(1 << pPin);
		}
		else
		if (pPin < 16){
			PORTC = PORTC & ~(1 << pPin);
		}	
	}
}


void setup()   {                
  for(unsigned char i =0; i < BUFFLEN; i++){
    mBuffer[i] = 0;
  }  
/*

  for(int i =0; i < 16; i++){
    digitalWrite(i, 1);  
  }  
*/
}

void randomOnOff(){
  int l,c;
  l = random(0,8);
  c = random(0,8);  
  unsigned char b = mBuffer[c];
  b = b ^ _BV(l);
  mBuffer[c] = b;

}

unsigned char mPos = 0;
void scanLines(){
  unsigned char l,c;
  l = mPos / 8;
  c = mPos % 8;  
  unsigned char b = mBuffer[c];
  b = b ^ _BV(l);
  mBuffer[c] = b;

  mPos = (mPos + 1) % 64;
}

void loop()                     
{
	//change the drawing
	//randomOnOff();
	scanLines();

	//draw the in memory image
	for (unsigned char c = 0; c < BUFFLEN; c++){
		PORTD = mBuffer[c];
		PORTB = ~_BV(c);
		PORTC = (c >= 6 ? ~_BV(c - 6) : 0xFF);
		//stay displayed to allow POV
		_delay_us(300);
		PORTD = 0;
		PORTB = 0xFF;
		PORTC = 0xFF;
	}

}


//
// main function
//
int main(void) {
	//all ports go output 
	DDRB = 0xFF;
	DDRC = 0xFF;
	DDRD = 0xFF;
	
	for (;;) loop();
}



