#!/bin/bash

size=${2:-"20"}
dir=${1:-"east"}

case "$dir" in
    west) bspc node @west -r -$size || bspc node @east -r -${size}
    ;;
    east) bspc node @west -r +$size || bspc node @east -r +${size}
    ;;
    north) bspc node @south -r -$size || bspc node @north -r -${size}
    ;;
    south) bspc node @south -r +$size || bspc node @north -r +${size}
    ;;
esac
