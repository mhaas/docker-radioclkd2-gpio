#!/bin/bash

if [[ -z "$GPIO_PON" ]]; then
    echo "Environment variable GPIO_PON is undefined. Bailing out!";
    exit 1
fi

if [[ -z "$GPIO_DATA" ]]; then
    echo "Environment variable GPIO_DATA is undefined. Bailing out!";
    exit 1
fi

# First, unexport pins if they had been previously exported

for i in "$GPIO_PON" "$GPIO_DATA"; do
    # unexport may yield errors if the pin is not exported. we ignore this
    echo "$i" > /sys/class/gpio/unexport 2> /dev/null
    echo "$i" >/sys/class/gpio/export
done

echo "out" > /sys/class/gpio/gpio${GPIO_PON}/direction

# Trigger transition from VCC to GND to turn on module
echo 1 > /sys/class/gpio/gpio${GPIO_PON}/value
sleep 1
echo 0 > /sys/class/gpio/gpio${GPIO_PON}/value

# for radioclkd2
echo "in" > /sys/class/gpio/gpio${GPIO_ATA}/direction
# Make sure to use a GPIO pin with interrupt support.
echo "both" > /sys/class/gpio/gpio${GPIO_DATA}/edge


if [[ "$GPIO_DATA_INVERT" == "1" || "$GPIO_DATA_INVERT" == "true" ]]; then
    INVERT_FLAG=":-DCD"
fi

if [[ "$DEBUG" == "1" || "$DEBUG" == "true" ]]; then
    DEBUG_FLAG="-v"
fi

CMD="radioclkd2 -s gpio ${DEBUG_FLAG} -d /sys/class/gpio/gpio${GPIO_DATA}/value${INVERT_FLAG} || exit 1"
echo "Running: $CMD"

$CMD
