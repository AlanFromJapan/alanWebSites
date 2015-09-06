/*
Solar Bug Bot
Firmware
for use with ATtiny2313
Chaos Computer Congress (24C3)
Mitch Altman
4-Jul-08

Distributed under Creative Commons 2.5 -- Attib & Share Alike

All credits to the author!
Found at http://www.tvbgone.com/mfaire/bugbot/bugbot.c
*/


/*
Ladyada has a great website about the MiniPOV kit, from which this project was hacked:
http://ladyada.net/make/minipov3/index.html
Her website also has a user forum, where people can ask and answer questions by people building
various projects, including this one:
http://www.ladyada.net/forums/
(Click on the link for MiniPOV).
*/



#include <avr/io.h>             // this contains all the IO port definitions
#include <avr/interrupt.h>      // interrupt vectors and definitions
#include <avr/sleep.h>          // definitions for power-down modes


/*
This project has a small vibrating motor, a small speaker, two LED "eyes"
and a small flexible solar panel.
The Solar panel can be glued over the PCB to create a shell for the BugBot.
If you attach the "eyes" at the end of pipe cleaners, and attach a pipe
cleaner "tail" to the motor, and attach the PCB to the battery case, and
attach 6 pipe cleaners to the battery case as "legs," then you have a cute
little critter.
As the motor vibrates, the BugBot moves on its flexible legs.
When light hits the solar panel it changes what the BugBot does.
*/


/*
This project provides an example of how to use the Analog Comparator and how to
use interrupts on the AVR.

The ATtiny2313 has two analog inputs that can be set up to compare two voltages.
When the voltage on AIN0 is greater than the voltage on AIN1 the Analog Comparator
Output is set (this is the ACO bit of the ACSR, the Analog Comparator Status Register).
The ACO bit can then trigger a processor interrupt.

For this project, the AVR normally makes the BugBot's eyes toggle in a semi-random-seeming
fashion.  But if light hits the solar panel, it triggers an interrupt.  An interrupt is
the same as a firmware function call, except the call is triggered by a hardware event
(rather than by a firmware instruction).  The function that is executed is the interrupt
service routine for that interrupt (for this project, the interrupt service routine is
one I wrote for the Analog Comparator Output).

This interrupt service routine looks at the ACO bit, and if it is set (meaning that a
bunch of light is hitting the solar panel), it makes the BugBot go though a song & dance
routine.  The song & dance continues until light stops hitting the solar panel, at which
point, the eyes blink quickly, and the firmware returns to the Main function, where the
eyes go into their semi-random-seeming sequence.  And we're ready for the next time light
hits the solar panel.
*/


/*
Parts list for this Solar BugBot project:
1   MiniPOV kit
2   AA batteries
1   3v motor (from a junked cassette player, or Jameco #231909)
1   flexible solar panel (Jameco #227985)
1   aligator clip   (for creating an off-center weight on the motor to make it vibrate when it spins)
1   100k ohm resistor   (to create a voltage to compare solar panel output voltage against)
1   470k ohm resistor   (to create a voltage to compare solar panel output voltage against)
1   1N4007  (to protect the semiconductors from back EMF from the motor)
1   2N3904  (to drive high current for turning the motor On and Off)
2   10 ohm resistor   (current limiting for the motor, and for the speaker)
1   small speaker (Jameco #673871)
1   220uF capacitor   (power supply bypass, to deal with surges of current from motor stopping and starting)
4   12" pipe cleaners   (eyes, legs, tail)
hot glue, or other suitable glue
*/


/*
The hardware for this project is very simple:
     ATtiny2313 has 20 pins:
       pin 1   connects to serial port programming circuitry
       pin 10  ground
       pin 12  AIN0 -- 3v solar cell
       pin 13  AIN1 -- voltage divider for solar cell voltage detection (100K to ground, 470K to +3v) -- creates 0.5v at this pin
       pin 15  PB3 -- tiny speaker
       pin 16  PB4 -- transistor to drive 3v motor
       pin 17  connects to serial port programming circuitry
       pin 18  PB6 -- LED eye -- also connects to serial port programming circuitry
       pin 19  PB7 -- LED eye -- also connects to serial port programming circuitry
       pin 20  +3v
    All other pins are unused

    This firmware requires that the clock frequency of the ATtiny
      is the default that it is shipped with:  8.0MHz
*/


// This function initializes the LEDs, motor, speaker, Analog Comparator, and interrupts
//   (For some reason, the compiler doesn't like functions without arguments, and I'm too tired to figure out why, so I put a dummy argument in, even though Init() doesn't need an argument).
void Init(int dummy) {
  DDRB  &= ~(1<<PB0);    // PB0 is AIN0 -- make it an input
  PORTB &= ~(1<<PB0);    // no Pull-up on PB0
  DDRB  |=  (1<<PB7);    // PB7 pin as output for eye LED
  DDRB  |=  (1<<PB6);    // PB6 pin as output for eye LED
  DDRB  |=  (1<<PB4);    // PB4 pin as output for motor
  DDRB  |=  (1<<PB3);    // PB3 pin as output for speaker
  PORTB |=  (1<<PB7);    // Initally PB7 LED is On
  PORTB &= ~(1<<PB6);    // Initally PB6 LED is Off
  PORTB &= ~(1<<PB4);    // Initally PB4 motor is Low
  PORTB &= ~(1<<PB3);    // Initally PB3 speaker is Off
  ACSR  |=  (1<<ACI);    // clear Analog Comparator interrupt
  ACSR  |=
    (0<<ACD)   |         // Comparator ON
    (0<<ACBG)  |         // Disconnect 1.23V reference from AIN0 (use AIN0 and AIN1 pins)
    (1<<ACIE)  |         // Comparator Interrupt enabled
    (0<<ACIC)  |         // input capture disabled
    (1<<ACIS1) |         // set interrupt bit on positive edge
    (1<<ACIS0);          //    (ACIS1 and ACIS0 == 11)
  sei();                 // enable global interrupts
}


// This function delays the specified number of 1/10 milliseconds
void delay_one_tenth_ms(unsigned long int ms) {
  unsigned long int timer;
  const unsigned long int DelayCount=87;  // this value was determined by trial and error

  while (ms != 0) {
    // Toggling PD0 is done here to force the compiler to do this loop, rather than optimize it away
    for (timer=0; timer <= DelayCount; timer++) {PIND |= 0b0000001;};
    ms--;
  }
}


// This function repeats the following a given number of times:
//   make the eyes blink a given number of times at a given blink rate
//   delay a given length of time
void BlinkEyes (int numBlinks, unsigned long int blinkRate, unsigned long int delayTime) {
  PORTB |=  (1<<PB6);                 // turn On LED on PB6
  PORTB &= ~(1<<PB7);                 // turn Off LED on PB7
  for (int i=0; i<numBlinks; i++) {
    PINB = (1<<PB7) | (1<<PB6);       // toggle LEDs on PB7 and PB6 numBlinks times
    delay_one_tenth_ms(blinkRate);
  }
  PORTB &= ~(1<<PB4);                 // turn Off motor on PB4
  PORTB &= ~(1<<PB6);                 // turn Off LED on PB6
  PORTB &= ~(1<<PB7);                 // turn Off LED on PB7
  delay_one_tenth_ms(delayTime);      // wait for delayTime
}


// This function performs one segment of a BugBot song & dance number.
// It turns On the motor on PB4, blinks (alternately) the LEDs on PB6 and PB7,
//   and toggles the speaker on PB3 at the period given by songPeriod (in units of .1 millisec),
//   doing all this for the length of time given by danceTime.
// The LEDs on PB6 and PB7 will toggle every lightTime * songPeriod
//   (e.g., if songPeriod = 100 and lightTime = 4, then the LEDs will toggle every 40ms).
// Every 6 times through the loop, we insert a 17.5ms pause to make the sound more interesting.
// The total time (in seconds) for the song and dance segment is:
//   ( songPeriod * danceTime / 10,000 ) + ( 175 * danceTime / 6 / 10,000 )
// which is the same as:
//   ( (songPeriod + 175/6) * danceTime ) / 10,000
void songAndDance(unsigned int danceTime, unsigned int songPeriod, unsigned int lightTime) {
  int lightTimeCount = 0;
  int songTimeCount = 0;
  const int songTime = 6;
  PORTB |=  (1<<PB4);                 // turn On motor on PB4
  PORTB |=  (1<<PB6);                 // turn On LED on PB6
  PORTB &= ~(1<<PB7);                 // turn Off LED on PB7
  for (int t=0; t<danceTime; t++) {
    delay_one_tenth_ms(songPeriod);   // wait songPeriod
    PINB = (1<<PB3);                  // toggle speaker
    // toggle the LEDs on PB7 and PB6 every time lightTimeCount reaches lightTime
    lightTimeCount++;
    if (lightTimeCount == lightTime) {
      lightTimeCount = 0;
      PINB = (1<<PB7) | (1<<PB6);     // toggle LEDs on PB7 and PB6
    }
    // every few times through the loop, insert a short pause to make the sound more interesting
    songTimeCount++;
    if (songTimeCount == songTime) {
      songTimeCount = 0;
      delay_one_tenth_ms(175);
    }
  }
  PORTB &= ~(1<<PB3);                 // turn Off speaker on PB3
  PORTB &= ~(1<<PB4);                 // turn Off motor on PB4
  PORTB &= ~(1<<PB6);                 // turn Off LED on PB6
  PORTB &= ~(1<<PB7);                 // turn Off LED on PB7
}


// Interrupt handler for ANA_COMP_vect
//   which will be executed every time the solar panel sees light
// The BugBot does a bunch of song & dance segments while light continues
//   to hit the solar panel.  When light no longer is hitting the solar
//   panel, the routine finishes by blinking the eyes quickly.
ISR(ANA_COMP_vect) {
    // start by blinking really quickly for a little while
    PORTB &= ~(1<<PB7);             // turn Off LED on PB7
    PORTB |=  (1<<PB6);             // turn On LED on PB6
    for (int i=0; i<10; i++) {
      PINB |= (1<<PB7) | (1<<PB6);  // toggle LEDs on PB7 and PB6
      delay_one_tenth_ms(700);      // 70ms delay
    }
    PORTB &= ~(1<<PB6);             // turn Off LED on PB6
    PORTB &= ~(1<<PB7);             // turn Off LED on PB7

    if ( bit_is_set(ACSR, ACO) ) {
      songAndDance( 75, 10, 4 );   // turn On motor, blink eyes, and sing for .29 sec
      delay_one_tenth_ms(10000);   // wait 1 sec
    }

    if ( bit_is_set(ACSR, ACO) ) {
      songAndDance( 100, 20, 5 );  // turn On motor, blink eyes, and sing for .49 sec
      delay_one_tenth_ms(10000);   // wait 1 sec
    }

    if ( bit_is_set(ACSR, ACO) ) {
      songAndDance( 50, 15, 6 );   // turn On motor, blink eyes, and sing for .22 sec
      delay_one_tenth_ms(5000);    // wait .5 sec
      songAndDance( 75, 10, 5 );   // turn On motor, blink eyes, and sing for .29 sec
      delay_one_tenth_ms(10000);   // wait 1 sec
    }

    if ( bit_is_set(ACSR, ACO) ) {
      songAndDance( 75, 10, 5 );   // turn On motor, blink eyes, and sing for .29 sec
      delay_one_tenth_ms(7000);    // wait .7 sec
      songAndDance( 75, 15, 5 );   // turn On motor, blink eyes, and sing for .33 sec
      delay_one_tenth_ms(5000);    // wait .5 sec
      songAndDance( 75, 20, 6 );   // turn On motor, blink eyes, and sing for .37 sec
      delay_one_tenth_ms(2500);    // wait .25 sec
      songAndDance( 75, 10, 4 );   // turn On motor, blink eyes, and sing for .29 sec
      delay_one_tenth_ms(10000);   // wait 1 sec
    }

    if ( bit_is_set(ACSR, ACO) ) {
      songAndDance( 75, 12, 5 );   // turn On motor, blink eyes, and sing for .31 sec
      delay_one_tenth_ms(5000);    // wait .5 sec
      songAndDance( 75, 17, 5 );   // turn On motor, blink eyes, and sing for .34 sec
      delay_one_tenth_ms(10000);   // wait 1 sec
    }

    if ( bit_is_set(ACSR, ACO) ) {
      songAndDance( 75, 20, 3 );   // turn On motor, blink eyes, and sing for .37 sec
      delay_one_tenth_ms(10000);   // wait 1 sec
    }

    if ( bit_is_set(ACSR, ACO) ) {
      songAndDance( 30, 10, 5 );   // turn On motor, blink eyes, and sing for .12 sec
      delay_one_tenth_ms(5000);    // wait .5 sec
      songAndDance( 30, 10, 5 );   // turn On motor, blink eyes, and sing for .12 sec
      delay_one_tenth_ms(10000);   // wait 1 sec
    }

    if ( bit_is_set(ACSR, ACO) ) {
      songAndDance( 90, 17, 3 );   // turn On motor, blink eyes, and sing for .42 sec
      delay_one_tenth_ms(10000);   // wait 1 sec
    }

    if ( bit_is_set(ACSR, ACO) ) {
      songAndDance( 75, 10, 4 );   // turn On motor, blink eyes, and sing for .29 sec
      delay_one_tenth_ms(10000);   // wait 1 sec
    }

    if ( bit_is_set(ACSR, ACO) ) {
      songAndDance( 100, 20, 5 );  // turn On motor, blink eyes, and sing for .49 sec
      delay_one_tenth_ms(10000);   // wait 1 sec
    }

    // blink really quickly for a little while before jumping back to main function
    PORTB &= ~(1<<PB7);             // turn Off LED on PB7
    PORTB |=  (1<<PB6);             // turn On LED on PB6
    for (int i=0; i<10; i++) {
      PINB |= (1<<PB7) | (1<<PB6);  // toggle LEDs on PB7 and PB6
      delay_one_tenth_ms(700);      // 70ms delay
    }
    PORTB &= ~(1<<PB6);             // turn Off LED on PB6
    PORTB &= ~(1<<PB7);             // turn Off LED on PB7
}


// Main
//
// The main function calls the Init function, which initializes the PORTB and Analog
// Comparator registers so that we get an interrupt when light hits the solar panel.
//
// Then there is a loop that toggles the eye LEDs at its idle pace (semi-random-seeming).
//
// When light hits the solar panel, the interrupt service routine keeps the BugBot going
// through a song and dance until light stops hitting the solar panel, and the Bug Bot
// reverts back to just toggling its eye LEDs at its idle pace.
//
// The program runs for about 10 minutes, after which the microcontroller is put into
// sleep mode to conserve batteries.

int main(void) {
  Init(0);  // initialize the LEDs, motor, speaker, Analog Comparator, and interrupts

  // Loop for about 10 minutes while waiting for light to shine on the solar cell
  //   (Analog Output Compare bit (AOC -- bit 5) in ACSR goes High when voltage from the solar cell is higher than 0.5v)
  // If a light shines on the solar cell, then go through a song and dance
  //   sequence in the interrupt service routine.
  // While waiting for light to shine on the solar cell, toggle the BugBot's eyes
  //   (i.e., the LEDs on PB7 and PB6) in some semi-random-seeming sequences.
  //   And turn on the motor every so often, too.
  int motorCount = 0;
  for (unsigned long int count=0; count<60; count++) {
    BlinkEyes ( 5, 2500,  20000); // blink eyes 5 times at 1/4 sec, then delay 2 seconds
    BlinkEyes (10, 1000, 30000);  // blink eyes 10 times at .1 sec, then delay 3 seconds
    BlinkEyes ( 5, 2500,  20000); // blink eyes 5 times at 1/4 sec, then delay 2 seconds
    BlinkEyes ( 5, 1000,  40000); // blink eyes 5 times at .1 sec, then delay 4 seconds
    motorCount++;
    if ( motorCount == 2 ) {
      motorCount = 0;             // turn On the motor every 2nd time through this loop
      PORTB |=  (1<<PB4);
      delay_one_tenth_ms(3000);   // turn the motor on PB4 On for just a little bit
      PORTB &= ~(1<<PB4);
    }
  }

  // put the microcontroller to sleep
  ACSR  |= (1<<ACD);          // ACD = 1 to disable Analog Comparator (bit 7)
  MCUCR |= (1<<SE);           // SE=1 (bit 5)
  MCUCR &= ~(1<<SM1);         // SM1:0=01 to enable Power Down Sleep Mode (bits 6, 4)
  MCUCR |= (1<<SM0);

  delay_one_tenth_ms(1000);   // wait .1 second
  PORTB = 0x00;               // turn Off all PORTB outputs
  DDRB = 0x00;                // make PORTB all inputs
  sleep_cpu();                // put CPU into Power Down Sleep Mode
}


