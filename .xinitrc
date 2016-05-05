#!/bin/bash

if [ -d /etc/X11/xinit/xinitrc.d ]
then
    for path in /etc/X11/xinit/xinitrc.d/*
    do
        [ -x "$path" ] && . "$path"
    done
    unset path
fi

# merge in defaults and keymaps

userresources=$HOME/.Xresources
if [ -f "$userresources" ]; then
    xrdb -merge "$userresources"
fi

usermodmap=$HOME/.Xmodmap
if [ -f "$usermodmap" ]; then
    xmodmap "$usermodmap"
fi

# start some nice programs

syndaemon -t -k -i 2 -d &            # disable touchpad click while typing
kbdd &                               # keyboard daemon
xbindkeys                            # enable brightness keys
redshift -l 19.43250:-99.13537 &     # colour temperature adjuster
urxvtd -q -o -f                      # terminal daemon
unagi &                              # enable transparency

exec awesome
