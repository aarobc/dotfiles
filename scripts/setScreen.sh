#!/bin/bash

if [ "$1" != "click" ]; then
    notify-send "else?"
    echo '{"text": "there", "alt": "alt", "tooltip": "tooltip", "class": "class", "percentage": "percentage" }'
    exit 0
fi
# now we do the action
output=`swaymsg -t get_workspaces --raw | jq -r '. [] | select(.focused == true) | .output'`

systemctl --user set-environment WLRF="-o $output"
sleep .1
systemctl --user restart xdg-desktop-portal-wlr.service
notify-send $output
echo '{"text": "clicked", "alt": "alt", "tooltip": "tooltip", "class": "class", "percentage": "percentage" }'
