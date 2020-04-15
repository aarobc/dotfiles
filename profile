
export EDITOR=/usr/bin/nano
export QT_QPA_PLATFORMTHEME="qt5ct"
export GTK2_RC_FILES="$HOME/.gtkrc-2.0"


if [ -d "$HOME/.local/bin" ]; then
    PATH="$HOME/.local/bin:$PATH"
fi

export PATH="$PATH:$HOME/local/bin"
export GTK_THEME=Adwaita:dark

# wayland/sway
export XKB_DEFAULT_LAYOUT=us
export XKB_DEFAULT_VARIANT=dvorak
export XKB_DEFAULT_MODEL=pc101
export XKB_DEFAULT_OPTIONS=caps:escape

xmodmap -e 'clear Lock' #ensures you're not stuck in CAPS on mode
xmodmap -e 'keycode 0x42=Escape' #remaps the keyboard so CAPS LOCK=ESC


path="$PATH/dotfiles/vim/bundle/powerline/scripts:$HOME/local/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"
path="$path:/usr/games"
path="$path:/usr/bin/core_perl"
# path="$path:/opt/android-studio/bin"
# path="$path:/opt/android-studio-3/bin"
export PATH=$path

# natural scrolling
# xinput set-button-map 14 1 2 3 5 4 7 6 8 9 10 11 12

# mac keyboard remap
# xmodmap ~/.xmodmaprc
# synclient HorizTwoFingerScroll=1 HorizEdgeScroll=0 VertEdgeScroll=0 VertScrollDelta=-247 HorizScrollDelta=-247
setxkbmap -option ctrl:nocaps
xmodmap -e "keycode 66 = Escape NoSymbol Escape"
/usr/lib/polkit-gnome/polkit-gnome-authentication-agent-1 &

# sh ~/.screenlayout/layout.sh
# workaround for annoying thing
# killall pulseaudio
# alsa force-reload
