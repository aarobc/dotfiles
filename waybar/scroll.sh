#!/bin/bash

# sadly this strategy isn't fast enough
monitor=$(hyprctl monitors -j | jq -r '.[] | select(.focused == true) | .name')
current=$(hyprctl activeworkspace -j | jq '.id')
highest=$(hyprctl workspaces -j | jq -r --arg mon "$monitor" '.[] | select(.monitor == $mon) | .id' | sort -rn | head -n 1)
lowest=$(hyprctl workspaces -j | jq -r --arg mon "$monitor" '.[] | select(.monitor == $mon) | .id' | sort -n | head -n 1)
# notify-send "$highest"

if [[ "$1" == "1" && "$current" == "$highest" ]]; then
  exit 1
fi

if [[ "$1" == "0" && "$current" == "$lowest" ]]; then
  exit 1
fi
