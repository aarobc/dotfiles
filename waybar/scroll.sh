#!/bin/bash

LOCKFILE="/tmp/my-action.lock"

exec 200>"$LOCKFILE"
if ! flock -n 200; then
    exit 0
fi

trap 'rm -f "$LOCKFILE"' EXIT

monitor=$(hyprctl monitors -j | jq -r '.[] | select(.focused == true) | .name')
current=$(hyprctl activeworkspace -j | jq '.id')
highest=$(hyprctl workspaces -j | jq -r --arg mon "$monitor" '.[] | select(.monitor == $mon) | .id' | sort -rn | head -n 1)
lowest=$(hyprctl workspaces -j | jq -r --arg mon "$monitor" '.[] | select(.monitor == $mon) | .id' | sort -n | head -n 1)

if [[ "$1" == "1" && "$current" == "$highest" ]]; then
  exit 1
fi

if [[ "$1" == "0" && "$current" == "$lowest" ]]; then
  exit 1
fi

if [[ "$1" == "1" ]]; then
  hyprctl dispatch workspace m+1
fi

if [[ "$1" == "0" ]]; then
  hyprctl dispatch workspace m-1
fi
