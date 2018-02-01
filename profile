
export EDITOR=/usr/bin/nano
export QT_QPA_PLATFORMTHEME="qt5ct"
export GTK2_RC_FILES="$HOME/.gtkrc-2.0"


if [ -d "$HOME/.local/bin" ]; then
    PATH="$HOME/.local/bin:$PATH"
fi

export PATH="$PATH:$HOME/local/bin"

xmodmap -e 'clear Lock' #ensures you're not stuck in CAPS on mode
xmodmap -e 'keycode 0x42=Escape' #remaps the keyboard so CAPS LOCK=ESC

# if hash setxkbmap 2>/dev/null; then
#     setxkbmap -option 'caps:ctrl_modifier'
# else
#     echo "no setxkbmap"
# fi


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

path="$PATH/dotfiles/vim/bundle/powerline/scripts:$HOME/local/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"
path="$path:/usr/games"
path="$path:/usr/bin/core_perl"
# path="$path:/opt/android-studio/bin"
# path="$path:/opt/android-studio-3/bin"
export PATH=$path
# xrandr --output eDP1 --auto --left-of HDMI3 --output HDMI3 --auto --scale 2x2 --right-of DP1
# xrandr --output eDP1 --mode 1920x1200 --left-of HDMI3 --output HDMI3  --right-of DP1
# xrandr --output eDP1 --mode 2560x1600 --left-of HDMI3 --output HDMI3  --right-of DP1
#xrandr --output eDP1 --mode 2560x1600 --left-of HDMI3
# natural scrolling
# xinput set-button-map 14 1 2 3 5 4 7 6 8 9 10 11 12

# mac keyboard remap
# xmodmap ~/.xmodmaprc
# synclient HorizTwoFingerScroll=1 HorizEdgeScroll=0 VertEdgeScroll=0 VertScrollDelta=-247 HorizScrollDelta=-247
setxkbmap -option ctrl:nocaps
xmodmap -e "keycode 66 = Escape NoSymbol Escape"

# sh ~/.screenlayout/layout.sh
# workaround for annoying thing
# killall pulseaudio
# alsa force-reload
