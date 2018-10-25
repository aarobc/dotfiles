# Path to your oh-my-zsh installation.

# Set name of the theme to load.
# Look in ~/.oh-my-zsh/themes/
# Optionally, if you set this to "random", it'll load a random theme each
# time that oh-my-zsh is loaded.
# load zgen
ZSH_DISABLE_COMPFIX=true
source ~/dotfiles/zgen/zgen.zsh
#source ~/.profile

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
    zgen load zsh-users/zsh-completions/docker-machine

    # completion-only repositories. Add optional path argument to specify
    # what subdirectory of the repository to add to your fpath.
    zgen load zsh-users/zsh-completions src

    # theme
    #zgen oh-my-zsh themes/arrow

    # save all to init script
    zgen save
fi

zstyle ':completion:*:*:docker:*' option-stacking yes
zstyle ':completion:*:*:docker-*:*' option-stacking yes

# to fix zgen do:
# zgen reset
# zgen selfupdate
# zgen update

# alias gitreset='git fetch --all && git reset --hard origin/master'
alias gitreset='git fetch --all && git reset --hard'
alias tmux='tmux -2'
alias gitl='git log --pretty=format:"%h - %an, %ar : %s"'
alias dc='docker-compose'
alias dm='docker-machine'
alias logoff='i3-msg exit'
alias gitroot='git rev-parse --show-toplevel'
alias rootOrcwd='[ -d .git ] || git rev-parse --git-dir > /dev/null 2>&1 && gitroot || pwd'

alias vue='docker run -it --rm -v "$PWD":"$PWD" -w "$PWD"  -u "$(id -u)" aarobc/vue-cli vue'

alias dcr='dc run --rm'
alias dcrp='dcr --service-ports'

alias v='$HOME/dotfiles/scripts/vimterm.py'
alias xclip='xclip -selection clipboard'
alias hibernate='$HOME/dotfiles/scripts/hibernate.sh'
alias gitaddall='echo -e "a\n*\nq\n"|git add -i'
alias used='du -Sh | sort -rh | head -n 15'
alias nautilus='nautilus --no-desktop'
alias phpd='docker run --rm -it -v $PWD:/var/www/html --workdir /var/www/html php php'
alias yarnd='docker run --rm -it -v $PWD:/var/www/html --workdir /var/www/html node yarn'
alias quickhttp='docker run --rm -it -v $PWD:/usr/share/nginx/html:ro -p 8080:80 nginx:alpine'

alias gitclean="git branch --merged master | grep -v '^[ *]*master$' | xargs git branch -d"
alias gitcleanup='git remote prune origin'

if hash nvim 2>/dev/null; then
    alias vim='nvim'
fi

path="$HOME/dotfiles/vim/bundle/powerline/scripts:$HOME/local/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"
path="$path:/usr/games"
path="$path:/usr/bin/core_perl"
path="$path:/opt/android-studio/bin"
# path="$path:/$HOME/Android/Sdk/platform-tools"
path="$path:/$HOME/go/bin"
path="$path:$HOME/.local/bin"
path="$path:$HOME/.npm-global/bin"
export PATH=$path
# export PATH="$HOME/dotfiles/vim/bundle/powerline/scripts:$HOME/local/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"
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

function qdns {
  if [ $1 ]
  then
    echo $1
    ip=`dig $1 +short`
    echo -e "IP:\n$ip"
    echo -e "www:\n`dig www.$1 +short`"

    # mx stuff
    mx=`dig mx $1 +short`
    mailip=`dig mail.$1 +short`
    ns=`dig ns $1 +short`

    echo -e "mx:\n$mx"
    echo -e "mail IP:\n$mailip"
    echo -e "NS:\n$ns"
  else
    echo "No domain specified"
  fi
}

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

# rotate video with ffmpeg
function rotate() {
  ffmpeg -i "$1" -c copy -metadata:s:v:0 rotate=180 "$2"
}
#hoping that this fixes the annoying issue when it doesn't workO
# if hash setxkbmap 2>/dev/null; then
#     # disable caps lock if it's on just in case
#     python -c 'from ctypes import *; X11 = cdll.LoadLibrary("libX11.so.6"); display = X11.XOpenDisplay(None); X11.XkbLockModifiers(display, c_uint(0x0100), c_uint(2), c_uint(0)); X11.XCloseDisplay(display)'
#     setxkbmap -option 'caps:ctrl_modifier'
# fi

#temp workaround for microphone volume issue
if hash amixer 2>/dev/null; then
    NOPe=`amixer -c 1 set Capture 20 2>/dev/null`
else
    # echo "no amixer"
fi

# including this ensures that new gnome-terminal tabs keep the parent `pwd` !
if [ -e /etc/profile.d/vte.sh ]; then
    . /etc/profile.d/vte.sh
fi

# set the option so you can use vim bindings in the shell
# set -o vi
