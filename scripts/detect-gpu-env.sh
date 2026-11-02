#!/bin/sh
# Dynamically determine and export AQ_DRM_DEVICES for Hyprland / Aquamarine.
# Prioritizes GPUs that currently have a connected display in /sys/class/drm.

_connected=""
_boot_vga=""
_other=""

for _status_file in /sys/class/drm/card[0-9]*-*/status; do
    [ -f "$_status_file" ] || continue
    if grep -q "^connected$" "$_status_file" 2>/dev/null; then
        _card="${_status_file#/sys/class/drm/}"
        _card="${_card%%-*}"
        _dev="/dev/dri/$_card"
        case ":$_connected:" in
            *":$_dev:"*) ;;
            *) _connected="${_connected:+$_connected:}$_dev" ;;
        esac
    fi
done

for _card_dir in /sys/class/drm/card[0-9]*; do
    [ -d "$_card_dir" ] || continue
    _card="${_card_dir#/sys/class/drm/}"
    case "$_card" in
        *-*) continue ;; # skip connector subdirectories
    esac
    _dev="/dev/dri/$_card"
    [ -e "$_dev" ] || continue
    case ":$_connected:$_boot_vga:$_other:" in
        *":$_dev:"*) ;;
        *)
            if [ -f "$_card_dir/device/boot_vga" ] && [ "$(cat "$_card_dir/device/boot_vga" 2>/dev/null)" = "1" ]; then
                _boot_vga="$_dev"
            else
                _other="${_other:+$_other:}$_dev"
            fi
            ;;
    esac
done

_remaining="${_boot_vga}${_boot_vga:+${_other:+:}}${_other}"

if [ -n "$_connected" ]; then
    export AQ_DRM_DEVICES="${_connected}${_remaining:+:$_remaining}"
elif [ -n "$_remaining" ]; then
    export AQ_DRM_DEVICES="$_remaining"
fi

unset _connected _boot_vga _other _remaining _status_file _card_dir _card _dev
