#!/bin/bash

# back up the existing files...
mv ~/.vim{,_bak}
mv ~/.bashrc{,_bak}
mv ~/.vimrc{,_bak}

# create the symlinks
ln -s ~/config/.vim ~/.vim
ln -s ~/config/.bashrc ~/.bashrc
ln -s ~/config/.vimrc ~/.vimrc

# setting the shell to use the new bashrc
source .bashrc

# using vundle for vim
git clone https://github.com/gmarik/vundle.git ~/.vim/bundle/vundle

# telling vim to install it
vim +BundleInstall +qall

