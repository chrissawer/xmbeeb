#!/bin/sh
set -e

mkdir -p build
cd build
beebasm -v -i ../xmrom.asm > xmrom.txt
beebasm -i ../xmrom.asm -do xmrom.ssd
cd ..
