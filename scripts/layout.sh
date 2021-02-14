#!/bin/bash


# check if sway
ee=`loginctl show-session $(loginctl | grep $(whoami) | awk '{print $1}') -p Type --value`

if [ $ee == 'wayland' ]; then

    active=`swaymsg -t get_inputs | jq 'map(select(has("xkb_active_layout_name")))[0].xkb_active_layout_name'`
    # notify-send "$active"
    #
    if [[ $active == *"Dvorak"* ]]; then
      swaymsg input "* xkb_layout us"
      notify-send "qwerty"
    else
      swaymsg input "* xkb_layout dvorak"
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
# xmodmap -e 'keycode 0x42=Escape' #remaps the keyboard so CAPS LOCK=ESC
