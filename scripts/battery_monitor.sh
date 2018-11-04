#!/bin/bash
set -x

while true
do
    state=` acpi | head -1 | awk '{print $3}'`
    charge=`acpi | head -1 | grep -P -o '[0-9]+(?=%)'`

    if [ $state = "Discharging," ] && [ $charge -le 20 ]; then
        notify-send -u critical "Battery low, ${charge}% remaining"
    fi
    sleep 120
done
