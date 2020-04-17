
export EDITOR=/usr/bin/vim
export QT_QPA_PLATFORMTHEME="qt5ct"
export GTK2_RC_FILES="$HOME/.gtkrc-2.0"


if [ -d "$HOME/.local/bin" ]; then
    PATH="$HOME/.local/bin:$PATH"
fi

PATH="$PATH:$HOME/local/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"
PATH="$PATH:$HOME/dotfiles/vim/bundle/powerline/scripts"
PATH="$PATH:/usr/games"
PATH="$PATH:/usr/bin/core_perl"
PATH="$PATH:/opt/android-studio/bin"
# path="$path:/$HOME/Android/Sdk/platform-tools"
PATH="$PATH:$HOME/go/bin"
PATH="$PATH:$HOME/.npm-global/bin"
PATH="$PATH:$HOME/.local/share/JetBrains/Toolbox/bin"
PATH="$PATH:/snap/bin"

export PATH=$PATH
# remove duplicate entrys from path
# path=$(printf "%s" "$PATH" | awk -v RS=':' '!a[$1]++ { if (NR > 1) printf RS; printf $1 }')
# export PATH=$path


# if hash xcape 2>/dev/null; then
#     xcape -e 'Caps_Lock=Escape'
# # else
# #     echo "no xcape"
# fi

# if hash amixer 2>/dev/null; then
#     amixer -c 1 set Capture 20 2>/dev/null
# # else
#     # echo "no amixer"
# fi

# ANDROID_EMULATOR_USE_SYSTEM_LIBS=1

# path="$path:/opt/android-studio/bin"
# path="$path:/opt/android-studio-3/bin"
# xrandr --output eDP1 --auto --left-of HDMI3 --output HDMI3 --auto --scale 2x2 --right-of DP1
# xrandr --output eDP1 --mode 1920x1200 --left-of HDMI3 --output HDMI3  --right-of DP1
# xrandr --output eDP1 --mode 2560x1600 --left-of HDMI3 --output HDMI3  --right-of DP1
#xrandr --output eDP1 --mode 2560x1600 --left-of HDMI3
# natural scrolling
# xinput set-button-map 14 1 2 3 5 4 7 6 8 9 10 11 12

# mac keyboard remap
# xmodmap ~/.xmodmaprc
# synclient HorizTwoFingerScroll=1 HorizEdgeScroll=0 VertEdgeScroll=0 VertScrollDelta=-247 HorizScrollDelta=-247
xmodmap ~/.Xmodmap

# TODO: set up this to be started by a daemon something or other
# this is probably not a great idea
polkitbin='/usr/lib/polkit-gnome/polkit-gnome-authentication-agent-1'

if [ -f "$polkitbin" ]; then
  $polkitbin &
fi

# workaround for annoying thing
# killall pulseaudio
# alsa force-reload
