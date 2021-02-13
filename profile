
export EDITOR=/usr/bin/vim
export QT_QPA_PLATFORMTHEME="qt5ct"
# export GTK2_RC_FILES="$HOME/.gtkrc-2.0"
export GTK_THEME=Adwaita:dark


if [ -d "$HOME/.local/bin" ]; then
    PATH="$HOME/.local/bin:$PATH"
fi

# wayland/sway
if [ "$XDG_SESSION_DESKTOP" = "sway" ]; then
    export XKB_DEFAULT_LAYOUT=us
    export XKB_DEFAULT_VARIANT=dvorak
    export XKB_DEFAULT_MODEL=pc101
    export XKB_DEFAULT_OPTIONS=caps:escape
    export KITTY_ENABLE_WAYLAND=1
    export MOZ_ENABLE_WAYLAND=1
    export XDG_SESSION_TYPE=wayland
    export XDG_CURRENT_DESKTOP=sway
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

# mac keyboard remap
# xmodmap ~/.xmodmaprc
# synclient HorizTwoFingerScroll=1 HorizEdgeScroll=0 VertEdgeScroll=0 VertScrollDelta=-247 HorizScrollDelta=-247
xmodmap ~/.Xmodmap
