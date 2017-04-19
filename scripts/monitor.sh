#!/bin/bash -xe
# Read the status of the relevant graphics adapter
# add to /etc/udev/rules.d/80-monitor-hotplug-rules
# KERNEL=="card0", SUBSYSTEM=="drm", ENV{DISPLAY}=":0", ENV{XAUTHORITY}="/home/.../.Xauthority", RUN+="/home/.../dotfiles/scripts/monitor.sh"



export DISPLAY=:0
# export XAUTHORITY=/home/ac/.Xauthority


# because otherwise weird issues
sleep 3


# make this into a function eventually so not bad
read STATUS1 < /sys/class/drm/card0-HDMI-A-1/status

if [ "$STATUS1" = "connected" ]; then
    xrandr --output HDMI1 --left-of eDP1 --auto --screen 0
else
    xrandr --output HDMI1 --off --screen 0
fi


read STATUS2 < /sys/class/drm/card0-HDMI-A-2/status
if [ "$STATUS2" = "connected" ]; then
    xrandr --output HDMI2 --left-of eDP1 --auto --screen 0
else
    xrandr --output HDMI2 --off --screen 0
fi

read STATUS3 < /sys/class/drm/card0-HDMI-A-3/status
if [ "$STATUS3" = "connected" ]; then
    # su ac -c 'xrandr --output HDMI3 --right-of eDP1 --auto --screen 0'
  # su ac -c 'notify-send Monitor "Connected"'
    # xrandr --output HDMI3 --right-of eDP1 --auto --screen 0
    xrandr --output HDMI3 --right-of eDP1 --auto --screen 0
else
    xrandr --output HDMI3 --off --screen 0
  # su ac -c 'notify-send Monitor "Disconnected"'
fi

# su ac -c 'notify-send Monitor "HDMI3: $STATUS3\nHDMI1: $STATUS1"'
# if [ "$STATUS3" = "connected" ] && [ "$STATUS2" = "connected" ]; then
#     # echo "both connected!"
#     /home/ac/dotfiles/scripts/fixLayout.py
# fi

# display port
read DP1 < /sys/class/drm/card0-DP-1/status
if [ "$DP1" = "connected" ]; then
    xrandr --output DP1 --right-of eDP1 --auto --screen 0
else
    xrandr --output DP1 --off --screen 0
fi

# after everything is reorganized, move the workspaces
sleep 1
# su ac -c 'notify-send python "Running"'
su ac -c '/home/ac/dotfiles/scripts/fixLayout.py'
