#!/bin/bash
# Starts the IPC proxy then waybar with the proxy instance signature.
# Required for Hyprland 0.55+ Lua config: "dispatch workspace N" now fails
# because the Lua evaluator can't parse it; the proxy translates to the
# Lua-compatible format before forwarding to Hyprland.

python3 ~/dotfiles/waybar/hypr-proxy.py &
sleep 0.3

export HYPRLAND_INSTANCE_SIGNATURE="${HYPRLAND_INSTANCE_SIGNATURE}-proxy"
exec waybar
