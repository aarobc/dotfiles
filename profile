
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

# set the screen timeout for 20 mins
#gxset dpms 0 0 1200
# sh ~/.screenlayout/layout.sh
# workaround for annoying thing
# killall pulseaudio
# alsa force-reload
