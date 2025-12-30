#!/bin/bash
layout=`setxkbmap -query | awk '/layout/ {print $2}'`
# echo $layout
if [ $layout == 'dvorak' ]; then
    setxkbmap us
else
    setxkbmap dvorak
fi


xmodmap -e 'clear Lock' #ensures you're not stuck in CAPS on mode
xmodmap -e "keycode 66 = Escape NoSymbol Escape"
# xmodmap -e 'keycode 0x42=Escape' #remaps the keyboard so CAPS LOCK=ESC
