#!/bin/bash

# A small script to set up the Pollin "DCF1" DCF77 receiver
# for dcf77 - useful for testing!

export PON=265
export DATA=266

for i in $PON $DATA; do
        echo $i > /sys/class/gpio/unexport
    done 

echo $PON > /sys/class/gpio/export

echo "out" > /sys/class/gpio/gpio${PON}/direction

# Trigger transition from VCC to GND to turn on module
echo 1 > /sys/class/gpio/gpio${PON}/value
sleep 1
echo 0 > /sys/class/gpio/gpio${PON}/value

# now call dcf77pi.. make sure to set the data pin correctly in its config.
# you may have to play around with the activehigh flag. I believe it
# should enabled for the DCF1?!

