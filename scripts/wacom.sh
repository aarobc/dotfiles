#!/bin/bash -xe
id=`xsetwacom --list devices | grep STYLUS | grep -o 'id: [0-9]*' | awk '{print $2}'`
active=`i3-msg -t get_workspaces | jq -r '. [] | select(.focused == true) | .output'`
xsetwacom --set $id MapToOutput $active
