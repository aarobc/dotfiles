#!/bin/bash
# Read the status of the relevant graphics adapter
# add to /etc/udev/rules.d/80-monitor-hotplug-rules
# KERNEL=="card0", SUBSYSTEM=="drm", ENV{DISPLAY}=":0", ENV{XAUTHORITY}="/home/.../.Xauthority", RUN+="/home/.../dotfiles/scripts/monitor.sh"



export DISPLAY=:0
xrandr --output HDMI1 --off --screen 0
xrandr --output HDMI2 --off --screen 0
xrandr --output DP1 --off --screen 0
sleep 1
# systemctl hibernate
sudo pm-hibernate
