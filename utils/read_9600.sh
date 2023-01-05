#!/bin/sh

DEV=/dev/ttyUSB0
SPEED=9600

stty -F $DEV $SPEED
cat < $DEV
