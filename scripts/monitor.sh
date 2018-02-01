#!/bin/bash -xe
# Read the status of the relevant graphics adapter
# add to /etc/udev/rules.d/80-monitor-hotplug-rules
# KERNEL=="card0", SUBSYSTEM=="drm", ENV{DISPLAY}=":0", ENV{XAUTHORITY}="/home/.../.Xauthority", RUN+="/home/.../dotfiles/scripts/monitor.sh"


export DISPLAY=":0.0"
# export XAUTHORITY=/home/ac/.Xauthority


# because otherwise weird issues
sleep 1


# make this into a function eventually so not bad

#!/bin/bash
# extend non-HiDPI external display on DP* above HiDPI internal display eDP*
# see also https://wiki.archlinux.org/index.php/HiDPI
# you may run into https://bugs.freedesktop.org/show_bug.cgi?id=39949
#                  https://bugs.launchpad.net/ubuntu/+source/xorg-server/+bug/883319

EXT=`xrandr --current | sed 's/^\(.*\) connected.*$/\1/p;d' | grep -v ^eDP | head -n 1`
INT=`xrandr --current | sed 's/^\(.*\) connected.*$/\1/p;d' | grep -v ^DP | head -n 1`

ext_w=`xrandr | sed 's/^'"${EXT}"' [^0-9]* \([0-9]\+\)x.*$/\1/p;d'`
ext_h=`xrandr | sed 's/^'"${EXT}"' [^0-9]* [0-9]\+x\([0-9]\+\).*$/\1/p;d'`
int_w=`xrandr | sed 's/^'"${INT}"' [^0-9]* \([0-9]\+\)x.*$/\1/p;d'`
off_w=`echo $(( ($int_w-$ext_w)/2 )) | sed 's/^-//'`

# xrandr --output "${INT}" --auto --pos ${off_w}x${ext_h} --scale 1x1  --output "${EXT}" --auto --scale 2x2 --pos 0x0

# cmd="xrandr --output ${INT} --auto --pos 0x0 --scale 1x1
#   --output ${EXT} --auto --scale 1.5x1.5 --pos ${int_w}x0"

scale=.9
cmd="xrandr --output ${INT} --auto --pos 0x0 --scale ${scale}x${scale}"
# cmd="xrandr --output ${INT} --auto --pos 0x0"

if [ -n "$EXT" ]; then
    # echo "Second display detected"
    notify-send Display "Evt Fired"
    cmd="$cmd --output ${EXT} --auto --scale 1x1 --right-of ${INT}"
fi

# echo $cmd
echo `$cmd`

# after everything is reorganized, move the workspaces
sleep 1
su ac -c '/home/ac/dotfiles/scripts/fixLayout.py'

# notify that running display script
notify-send Display "Evt Fired"
