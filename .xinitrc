xbindkeys
xrdb -merge ~/.Xresources
dunst &
compton --config ~/.config/compton/compton.conf -b
#bspwm
exec awesome -c ~/.config/awesome/rc.lua
