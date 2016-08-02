# ~/.profile: executed by the command interpreter for login shells.
# This file is not read by bash(1), if ~/.bash_profile or ~/.bash_login
# exists.
# see /usr/share/doc/bash/examples/startup-files for examples.
# the files are located in the bash-doc package.

# the default umask is set in /etc/profile; for setting the umask
# for ssh logins, install and configure the libpam-umask package.
#umask 022

# if running bash
if [ -n "$BASH_VERSION" ]; then
    # include .bashrc if it exists
    if [ -f "$HOME/.bashrc" ]; then
	. "$HOME/.bashrc"
    fi
fi

# set PATH so it includes user's private bin if it exists
if [ -d "$HOME/bin" ] ; then
    PATH="$HOME/bin:$PATH"
fi

if [ -d "$HOME/.local/bin" ]; then
    PATH="$HOME/.local/bin:$PATH"
fi

export PATH="$PATH:$HOME/local/bin"

if hash setxkbmap 2>/dev/null; then
    setxkbmap -option 'caps:ctrl_modifier'
else
    echo "no setxkbmap"
fi


if hash xcape 2>/dev/null; then
    xcape -e 'Caps_Lock=Escape'
# else
#     echo "no xcape"
fi

if hash amixer 2>/dev/null; then
    amixer -c 1 set Capture 20 2>/dev/null
# else
    # echo "no amixer"
fi

# set the screen timeout for 20 mins
xset dpms 0 0 1200
# sh ~/.screenlayout/layout.sh
# workaround for annoying thing
# killall pulseaudio
# alsa force-reload
