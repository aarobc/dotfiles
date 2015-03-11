#!/bin/bash
# Read the status of the relevant graphics adapter
# add to /etc/udev/rules.d/80-monitor-hotplug-rules
# KERNEL=="card0", SUBSYSTEM=="drm", ENV{DISPLAY}=":0", ENV{XAUTHORITY}="/home/.../.Xauthority", RUN+="/home/.../dotfiles/scripts/monitor.sh"



export DISPLAY=:0
# export XAUTHORITY=/home/vk/.Xauthority


# because otherwise weird issues
sleep 2


# make this into a function eventually so not bad
read STATUS1 < /sys/class/drm/card0-HDMI-A-1/status

if [ "$STATUS1" = "connected" ]; then
    xrandr --output HDMI1 --right-of eDP1 --auto --screen 0
else
    xrandr --output HDMI1 --off --screen 0
fi


read STATUS2 < /sys/class/drm/card0-HDMI-A-2/status
if [ "$STATUS2" = "connected" ]; then
    xrandr --output HDMI2 --right-of HDMI1 --auto --screen 0
else
    xrandr --output HDMI2 --off --screen 0
fi

notify-send Monitor "HDMI2: $STATUS2\nHDMI1: $STATUS1"
if [ "$STATUS1" = "connected" ] && [ "$STATUS2" = "connected" ]; then
    # echo "both connected!"
    /home/ac/dotfiles/scripts/fixLayout.py
fi
