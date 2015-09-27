#!/bin/bash

# update X resources db
xrdb -merge ~/.Xresources

# update key mappings
if [ -s ~/.Xmodmap  ]; then
    xmodmap ~/.Xmodmap
fi

# disable touchpad click while typing
syndaemon -t -k -i 2 -d &

# start keyboard daemon
kbdd &

# run this to enable brightness keys
xbindkeys

# start rxvt-unicode daemon
urxvtd -q -o -f

# start the color temperature adjuster
redshift -l 19.43250:-99.13537 &

# run this lovely window manager
exec awesome
