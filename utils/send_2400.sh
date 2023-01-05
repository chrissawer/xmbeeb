#!/bin/sh

DEV=/dev/ttyUSB0
SPEED=2400

stty -F $DEV $SPEED
cat $1 > $DEV
