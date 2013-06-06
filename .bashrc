# .bashrc

# User specific aliases and functions
alias mv='mv -i'
alias rm='rm -i'
alias cp='cp -i'

#extract tar.gz files
alias untar='tar -xzvf'

export PATH=$PATH:$HOME/.nodejs/bin
# Source global definitions
export TERM="xterm-256color"
if [ -f /etc/bashrc ]; then
	. /etc/bashrc
fi

# for the multi-line prompt:
PS1="[\[\033[32m\]\w]\[\033[0m\]\n\[\033[1;36m\]\u\[\033[1;33m\]-> \[\033[0m\]"
