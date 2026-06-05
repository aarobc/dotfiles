#!/bin/sh

# 1. Grab the workspace names
workspaces=$(swaymsg -t get_workspaces | jq -r '.[].name')

# 2. Count them
count=$(echo "$workspaces" | wc -l)

# 3. Pipe them to Wofi, forcing the exact line count (-L)
echo "$workspaces" | wofi --dmenu -p 'Go to Workspace:' -L "$count" | xargs -r -I {} swaymsg workspace '{}'
