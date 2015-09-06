#!/bin/bash

#avrdude -c avrispv2 -p m328p -P /dev/ttyACM0 -U flash:w:ATmegaBOOT_168_atmega328.hex
#avrdude  -c avrispv2 -p m328p -P /dev/ttyACM0 -U flash:w:Blink.cpp.hex:i 


#read
#avrdude -c avrispv2 -p m328p -P /dev/ttyACM0 -U lfuse:r:lowfuse.txt:s
#write
avrdude -c avrispv2 -p m328p -P /dev/ttyACM0 -U lfuse:w:0xd7:m

