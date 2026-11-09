#!/bin/bash

LOCKFILE="/tmp/my-action.lock"

exec 200>"$LOCKFILE"
if ! flock -n 200; then
    exit 0
fi

trap 'rm -f "$LOCKFILE"' EXIT

monitor=$(hyprctl monitors -j | jq -r '.[] | select(.focused == true) | .name')
current=$(hyprctl activeworkspace -j | jq -r 'if .id and .id > 0 then (.id | tostring) else ("\"name:" + .name + "\"") end')

mapfile -t workspaces < <(hyprctl workspaces -j | jq -r --arg mon "$monitor" '
  [ .[] | select(.monitor == $mon and (.special | not) and (.name | startswith("special:") | not)) ]
  | sort_by(if .id and .id > 0 then .id else 999999 end, .name)
  | .[] | (if .id and .id > 0 then (.id | tostring) else ("\"name:" + .name + "\"") end)
')

idx=-1
for i in "${!workspaces[@]}"; do
    if [[ "${workspaces[$i]}" == "$current" ]]; then
        idx=$i
        break
    fi
done

if [[ $idx -lt 0 || ${#workspaces[@]} -lt 2 ]]; then
    exit 0
fi

if [[ "$1" == "1" ]]; then
    next_idx=$((idx + 1))
    if [[ $next_idx -lt ${#workspaces[@]} ]]; then
        target="${workspaces[$next_idx]}"
        hyprctl dispatch "hl.dsp.focus({workspace=$target})"
    fi
fi

if [[ "$1" == "0" ]]; then
    prev_idx=$((idx - 1))
    if [[ $prev_idx -ge 0 ]]; then
        target="${workspaces[$prev_idx]}"
        hyprctl dispatch "hl.dsp.focus({workspace=$target})"
    fi
fi
