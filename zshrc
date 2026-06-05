# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

ZSH_DISABLE_COMPFIX=true
source ~/src/zgen/zgen.zsh
# source ~/.profile

# check if there's no init script
if ! zgen saved; then
    echo "Creating a zgen save"

    zgen load romkatv/powerlevel10k powerlevel10k
    zgen oh-my-zsh
        # plugins
    # zgen oh-my-zsh plugins/git
    zgen oh-my-zsh plugins/gitfast
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

# to preserve autocomplete behavior in the legacy setup
alias dc='docker-compose'
alias dcr='dc run --rm'
alias dcrp='dcr --service-ports --use-aliases'
alias dce='dc exec'

alias used='du -Sh | sort -rh | head -n 15'
alias phpd='docker run --rm -it -v $PWD:/var/www/html --workdir /var/www/html php php'
alias yarnd='docker run --rm -it -v $PWD:/var/www/html --workdir /var/www/html node yarn'
alias quickhttp='docker run --rm -it -v $PWD:/usr/share/nginx/html:ro -p 8081:80 -p 4443:443 aarobc/quickhttp'

alias gitclean="git branch --merged master | grep -v '^[ *]*master$' | xargs git branch -d"
alias gitcleanup='git remote prune origin'
alias clearlaravel='dcr chat sh -c "./artisan cache:clear && ./artisan config:clear && ./artisan config:cache"'
alias pr='~/dotfiles/scripts/go-to-source pr'
alias displays='swaymsg -t get_outputs'

if hash nvim 2>/dev/null; then
    alias vim='nvim'
fi

# export MANPATH="/usr/local/man:$MANPATH"
export GIT_EDITOR=vim
export EDITOR=vim
export VISUAL=vim
export ZSHZ_CASE=smart


# see also ./profile that's symlinked within ~/.config/environment.d/
# for the path for now:
# PATH=~/.local/bin:$PATH
# PATH=~/.npm-global/bin:$PATH
export PATH=$PATH:~/dotfiles/scripts
export PATH=~/.node_modules/bin:$PATH
export PATH=$PATH:~/go/bin
export N_PREFIX=$HOME/.local

# workaround to allow sudo to be used with aliases
alias sudo='sudo '

function gewt() {
    local branch_name="$1"
    command gewt "$@" && cd "$(dirname "$(git rev-parse --show-toplevel)")/$branch_name"
}

function gnwt() {
    local branch_name="$1"
    command gnwt "$@" && cd "$(dirname "$(git rev-parse --show-toplevel)")/$branch_name"
}

# set the option so you can use vim bindings in the shell
# set -o vi

POWERLEVEL9K_CONFIG_FILE="~/.config/p10k.zsh"
# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.config/p10k.zsh ]] || source ~/.config/p10k.zsh

# bun completions
[ -s "/tmp/bun-latest/_bun" ] && source "/tmp/bun-latest/_bun"
