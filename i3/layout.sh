#!/bin/bash
layout=`setxkbmap -query | awk '/layout/ {print $2}'`
# echo $layout
if [ $layout == 'dvorak' ]; then
    setxkbmap us
else
    setxkbmap dvorak
fi
