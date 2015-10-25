# Path to your oh-my-zsh installation.

# Set name of the theme to load.
# Look in ~/.oh-my-zsh/themes/
# Optionally, if you set this to "random", it'll load a random theme each
# time that oh-my-zsh is loaded.
# load zgen
source ~/dotfiles/zgen/zgen.zsh

#custom theme
source ~/dotfiles/agnoster.zsh-theme
# check if there's no init script
if ! zgen saved; then
    echo "Creating a zgen save"

    zgen oh-my-zsh
        # plugins
    zgen oh-my-zsh plugins/git
    zgen oh-my-zsh plugins/sudo
    zgen oh-my-zsh plugins/docker
    zgen oh-my-zsh plugins/command-not-found
    zgen load zsh-users/zsh-syntax-highlighting
    #zgen load ~/dotfiles/agnoster.zsh-theme

    # completion-only repositories. Add optional path argument to specify
    # what subdirectory of the repository to add to your fpath.
    zgen load zsh-users/zsh-completions src

    # theme
    #zgen oh-my-zsh themes/arrow

    # save all to init script
    zgen save
fi


alias gitreset='git fetch --all && git reset --hard origin/master'
alias tmux='tmux -2'
alias gitl='git log --pretty=format:"%h - %an, %ar : %s"'
alias dc='docker-compose'
alias logoff='i3-msg exit'
alias gitroot='git rev-parse --show-toplevel'
alias dcrrm='dc run --rm'
alias v='$HOME/dotfiles/scripts/vimterm.py'
alias xclip='xclip -selection clipboard'
alias hibernate='$HOME/dotfiles/scripts/hibernate.sh'
alias gitaddall='echo -e "a\n*\nq\n"|git add -i'

if hash nvim 2>/dev/null; then
    alias vim='nvim'
fi

export PATH="$HOME/dotfiles/vim/bundle/powerline/scripts:$HOME/local/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"
#export "$PATH:$HOME/Library/Python/2.7/bin"
# export MANPATH="/usr/local/man:$MANPATH"
export GIT_EDITOR=vim
export EDITOR=vim
export VISUAL=vim


# You may need to manually set your language environment
#export LANG=en_US.UTF-8
# Setting to 256 for working neovim syntax. must set to just xterm for vim
export TERM=xterm-256color
#[ -n "$TMUX" ] && export TERM=screen-256color

#if [[ -r /usr/local/lib/python2.7/dist-packages/powerline/bindings/zsh/powerline.zsh ]]; then
    #source /usr/local/lib/python2.7/dist-packages/powerline/bindings/zsh/powerline.zsh
#fi


# Extract Files #
function extract {
  if [ -f $1 ] ; then
      case $1 in
          *.tar.bz2)   tar xvjf $1    ;;
          *.tar.gz)    tar xvzf $1    ;;
          *.tar.xz)    tar xf $1    ;;
          *.bz2)       bunzip2 $1     ;;
          *.rar)       rar x $1       ;;
          *.gz)        gunzip $1      ;;
          *.tar)       tar xvf $1     ;;
          *.tbz2)      tar xvjf $1    ;;
          *.tgz)       tar xvzf $1    ;;
          *.zip)       unzip $1       ;;
          *.Z)         uncompress $1  ;;
          *.7z)        7z x $1        ;;
          *)           echo "don't know how to extract '$1'..." ;;
      esac
  else
      echo "'$1' is not a valid file!"
  fi
}

#hoping that this fixes the annoying issue when it doesn't workO
if hash setxkbmap 2>/dev/null; then
    # disable caps lock if it's on just in case
    python -c 'from ctypes import *; X11 = cdll.LoadLibrary("libX11.so.6"); display = X11.XOpenDisplay(None); X11.XkbLockModifiers(display, c_uint(0x0100), c_uint(2), c_uint(0)); X11.XCloseDisplay(display)'
    setxkbmap -option 'caps:ctrl_modifier'
fi

#temp workaround for microphone volume issue
if hash amixer 2>/dev/null; then
    NOPe=`amixer -c 1 set Capture 20 2>/dev/null`
else
    echo "no amixer"
fi
