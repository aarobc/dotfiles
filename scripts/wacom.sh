#!/bin/bash -xe

identifier=`swaymsg -t get_inputs -r | jq -r '.[] | select(.type == "tablet_tool").identifier'`
output=`swaymsg -t get_workspaces -r | jq -r '.[] | select(.focused == true) | .output'`

swaymsg input $identifier map_to_output $output
