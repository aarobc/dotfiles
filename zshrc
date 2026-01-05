# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

ZSH_DISABLE_COMPFIX=true
source ~/src/zgen/zgen.zsh
# source ~/.profile

#custom theme
# source ~/dotfiles/agnoster.zsh-theme
# check if there's no init script
if ! zgen saved; then
    echo "Creating a zgen save"

    zgen load romkatv/powerlevel10k powerlevel10k
    zgen oh-my-zsh
        # plugins
    zgen oh-my-zsh plugins/git
    zgen oh-my-zsh plugins/sudo
    zgen oh-my-zsh plugins/docker
    zgen oh-my-zsh plugins/command-not-found
    zgen load zsh-users/zsh-syntax-highlighting
    zgen load zsh-users/zsh-completions/docker-machine
    # zgen load popstas/zsh-command-time
    # directory jumping
    zgen load agkozak/zsh-z

    # completion-only repositories. Add optional path argument to specify
    # what subdirectory of the repository to add to your fpath.
    zgen load zsh-users/zsh-completions src

    # save all to init script
    zgen save
fi

zstyle ':completion:*:*:docker:*' option-stacking yes

# to fix zgen do:
# zgen reset
# zgen selfupdate
# zgen update

# alias gitreset='git fetch --all && git reset --hard origin/master'
alias gitreset='git fetch --all && git reset --hard'
alias tmux='tmux -2'
alias gitl='git log --pretty=format:"%h - %an, %ar : %s"'
alias dm='docker-machine'
alias logoff='i3-msg exit'
alias gitroot='git rev-parse --show-toplevel'
alias rootOrcwd='[ -d .git ] || git rev-parse --git-dir > /dev/null 2>&1 && gitroot || pwd'

# alias vue='docker run -it --rm -v "$PWD":"$PWD" -w "$PWD"  -u "$(id -u)" aarobc/vue-cli vue'

# alias dc='docker compose'
alias dc='docker compose'
alias dcr='dc run --rm'
alias dcrp='dcr --service-ports --use-aliases'
alias dce='dc exec'

alias v=$HOME/dotfiles/scripts/vimterm.py
alias xclip='xclip -selection clipboard'
alias hibernate=$HOME/dotfiles/scripts/hibernate.sh
alias gitaddall='echo -e "a\n*\nq\n"|git add -i'
alias used='du -Sh | sort -rh | head -n 15'
alias nautilus='nautilus --no-desktop'
alias phpd='docker run --rm -it -v $PWD:/var/www/html --workdir /var/www/html php php'
alias yarnd='docker run --rm -it -v $PWD:/var/www/html --workdir /var/www/html node yarn'
alias quickhttp='docker run --rm -it -v $PWD:/usr/share/nginx/html:ro -p 8080:80 -p 4443:443 aarobc/quickhttp'

alias gitclean="git branch --merged master | grep -v '^[ *]*master$' | xargs git branch -d"
alias gitcleanup='git remote prune origin'
alias clearlaravel='dcr chat sh -c "./artisan cache:clear && ./artisan config:clear && ./artisan config:cache"'
alias pr='~/dotfiles/scripts/go-to-source pr'
alias displays='swaymsg -t get_outputs'

# alias twiliod='docker run --rm -it -v $HOME/.twilio-cli:/root/.twilio-cli -v $PWD:$PWD --workdir $PWD aarobc/twilio-cli twilio'

if hash nvim 2>/dev/null; then
    alias vim='nvim'
fi

# export MANPATH="/usr/local/man:$MANPATH"
export GIT_EDITOR=vim
export EDITOR=vim
export VISUAL=vim
export ZSHZ_CASE=smart

# You may need to manually set your language environment
#export LANG=en_US.UTF-8
# Setting to 256 for working neovim syntax. must set to just xterm for vim
#[ -n "$TMUX" ] && export TERM=screen-256color


# for the path for now:
PATH=~/.local/bin:$PATH
PATH=~/.npm-global/bin:$PATH
export PATH=~/.node_modules/bin:$PATH
export N_PREFIX=$HOME/.local

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

genuuid()
{
    od -x /dev/urandom | head -1 | awk '{OFS="-"; print $2$3,$4,$5,$6,$7$8$9}'
}

# Extract Files #
function extract {
  if [ -f $1 ] ; then
      case $1 in
          *.tar.bz2)   tar xvjf $1    ;;
          *.tar.gz)    tar xvzf $1    ;;
          *.tar.xz)    tar xf $1      ;;
          *.bz2)       bunzip2 $1     ;;
          *.gz)        gunzip $1      ;;
          *.tar)       tar xvf $1     ;;
          *.tbz2)      tar xvjf $1    ;;
          *.tgz)       tar xvzf $1    ;;
          *.zip)       unzip $1       ;;
          *.Z)         uncompress $1  ;;
          *.7z)        7z x $1        ;;
          *.rar)       unrar e $1     ;;
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

# workaround to allow sudo to be used with aliases
alias sudo='sudo '

function runfast() {
  if [ -z "$1" ]
  then
    echo "no args"
    return 0
  fi

  bs=`du -csh --block-size=1M . | grep total | grep -Eo '[0-9]*'`
  big=$((($bs | 15) + 1))M

  ramdir=/media/ramdisk

  echo "Creating temp ramdisk at $ramdir with size $big..."
  sudo mkdir -p $ramdir
  sudo mount -t tmpfs -o size=$big tmpfs $ramdir/
  echo "setting permissions..."
  sudo chown `whoami`:`whoami` $ramdir
  echo "copying contents..."
  cp -r ./. $ramdir/
  cd $ramdir
  echo "running command"
  echo "$@"
  eval "$@"
  cd -
  sleep 1
  echo "unmounting ramdisk"
  sudo umount $ramdir
}



# including this ensures that new gnome-terminal tabs keep the parent `pwd` !
# if [ -e /etc/profile.d/vte.sh ]; then
#     . /etc/profile.d/vte.sh
# fi

# set the option so you can use vim bindings in the shell
# set -o vi

POWERLEVEL9K_CONFIG_FILE="~/.config/p10k.zsh"
# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.config/p10k.zsh ]] || source ~/.config/p10k.zsh
