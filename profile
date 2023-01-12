# # wayland/sway
if [ "$XDG_SESSION_DESKTOP" != "sway" ]; then
    msg="not sway, exporting vars from .config/environment.d manually..."
    notify-send $msg
    echo $msg
    set -o allexport
    for f in ~/.config/environment.d/*; do source $f; done
    set +o allexport

    # remove duplicates in PATH
    export PATH=$(echo -n $PATH | awk -v RS=: '!($0 in a) {a[$0]; printf("%s%s", length(a) > 1 ? ":" : "", $0)}')
else
    notify-send "already loaded"
fi

# mac keyboard remap
# xmodmap ~/.xmodmaprc
# synclient HorizTwoFingerScroll=1 HorizEdgeScroll=0 VertEdgeScroll=0 VertScrollDelta=-247 HorizScrollDelta=-247
# xmodmap ~/.Xmodmap
gsettings set org.gnome.desktop.input-sources xkb-options "['caps:escape']"
