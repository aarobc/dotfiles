#!/bin/bash

case "$1" in
    menu)
        fuzzel
        # choice=$(compgen -c | sort -u | fuzzel --dmenu --prompt='▶ ')
        # [ -n "$choice" ] && bash -c "$choice &"
        ;;
    go-to-ws)
        workspaces=$(swaymsg -t get_workspaces | jq -r '.[].name')
        count=$(echo "$workspaces" | wc -l)
        echo "$workspaces" | fuzzel --dmenu --prompt='Go to Workspace: ' --lines="$count" \
            | xargs -r -I {} swaymsg workspace '{}'
        ;;
    move-ws)
        swaymsg -t get_workspaces | jq -r '.[].name' \
            | fuzzel --dmenu --prompt='Move to Workspace: ' \
            | xargs -r -I {} swaymsg move container to workspace '{}'
        ;;
    rename-ws)
        echo '' | fuzzel --dmenu --lines=0 --prompt='Rename to: ' \
            | xargs -r -I {} swaymsg rename workspace to '{}'
        ;;
    *)
        echo "Usage: $0 {menu|go-to-ws|move-ws|rename-ws}" >&2
        exit 1
        ;;
esac
