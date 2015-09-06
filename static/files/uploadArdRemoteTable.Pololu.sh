#!/bin/bash

#avrdude -c avrispv2 -p m328p -P /dev/ttyACM0 -U flash:w:ATmegaBOOT_168_atmega328.hex
avrdude  -c avrispv2 -p m328p -P /dev/ttyACM0 -U flash:w:./hex/ArdRemoteTable.cpp.hex:i 
