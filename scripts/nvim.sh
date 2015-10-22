#!/bin/bash
sudo yum -y install autoconf automake cmake gcc gcc-c++ libtool make pkgconfig unzip
git clone https://github.com/neovim/neovim.git ~/neovim
cd ~/neovim && \
make CMAKE_EXTRA_FLAGS="-DCMAKE_INSTALL_PREFIX:PATH=$HOME/local" && \
make install
