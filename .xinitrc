#!/bin/bash

userresources=$HOME/.Xresources
usermodmap=$HOME/.Xmodmap

# merge in defaults and keymaps

if [ -f "$userresources" ]; then
    xrdb -merge "$userresources"
fi

if [ -f "$usermodmap" ]; then
    xmodmap "$usermodmap"
fi

# start some nice programs

# disable touchpad click while typing
syndaemon -t -k -i 2 -d &

# enable some fn keys
xbindkeys

# keyboard daemon
kbdd &

# colour temperature adjuster
redshift -l 19.43250:-99.13537 &

# terminal daemon
urxvtd -q -o -f

# enable transparency
#unagi &

# remove exec to leave in prompt when exiting awesome
#exec awesome
awesome
