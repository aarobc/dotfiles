#!/bin/bash

# back up the existing files...
mv ~/.vim{,_bak}
mv ~/.bashrc{,_bak}
mv ~/.vimrc{,_bak}

# create the symlinks
ln -s ~/dotfiles/.vim ~/.vim
ln -s ~/dotfiles/.bashrc ~/.bashrc
ln -s ~/dotfiles/.vimrc ~/.vimrc
ln -s ~/dotfiles/.tmux.conf ~/.tmux.conf

# setting the shell to use the new bashrc
source .bashrc

# using vundle for vim
git clone https://github.com/gmarik/vundle.git ~/.vim/bundle/vundle

# telling vim to install it
vim +BundleInstall +qall

