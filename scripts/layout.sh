#!/bin/bash

# only sway supported for this rn
if [ "$1" == "check" ]; then
    swaymsg -t get_inputs -r | jq -r '[.[] | select(.type == "keyboard")][0].xkb_active_layout_name | match("\\((.*)\\)").captures[0].string'
    exit 0
fi

# check if sway
ee=`loginctl show-session $(loginctl | grep $(whoami) | awk '{print $1}') -p Type --value`

if [ $ee == 'wayland' ]; then

    active=`swaymsg -t get_inputs | jq 'map(select(has("xkb_active_layout_name")))[0].xkb_active_layout_name'`
    # notify-send "$active"
    #
    if [[ $active == *"Dvorak"* ]]; then
      # swaymsg input "* xkb_layout us"
      notify-send "qwerty not allowed"
    else
      swaymsg input "* xkb_variant dvorak"
      notify-send "dvorak"
    fi

    exit
fi

# otherwise we assume it's using xorg
layout=`setxkbmap -query | awk '/layout/ {print $2}'`
# echo $layout
if [ $layout == 'dvorak' ]; then
    setxkbmap us
else
    setxkbmap dvorak
fi


xmodmap -e 'clear Lock' #ensures you're not stuck in CAPS on mode
xmodmap -e "keycode 66 = Escape NoSymbol Escape"
