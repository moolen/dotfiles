export _JAVA_AWT_WM_NONREPARENTING=1

# bspwm
xbindkeys
xrdb -merge ~/.Xresources
dunst &
compton --config ~/.config/compton/compton.conf -b
nm-applet &
bspwm

# awesome
# exec awesome -c ~/.config/awesome/rc.lua > ~/.awesome.log 2>&1
