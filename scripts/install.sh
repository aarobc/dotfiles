#!/bin/bash
set -e
#variety
sudo add-apt-repository ppa:peterlevi/ppa
#neovim
sudo add-apt-repository -y ppa:neovim-ppa/unstable
sudo apt-get update
sudo apt-get install -y neovim

sudo apt-get install -y python-dev python-pip python3-dev python3-pip

sudo apt-get install -y arandr

sudo apt-get install -y variety
sudo apt-get install -y feh
# for dd
sudo apt-get install -y pv

sudo apt-get install -y zsh
sudo apt-get install -y git
sudo apt-get install -y checkinstall
sudo apt-get install -y compton
sudo apt-get install -y pasystray
sudo apt-get install -y xclip
sudo apt-get install -y network-manager-openvpn

sudo chsh -s /bin/zsh
#TODO: test
# https://github.com/alols/xcape
sudo apt-get install -y gcc make pkg-config libx11-dev libxtst-dev libxi-dev
git clone https://github.com/alols/xcape.git /tmp/xcape
cd /tmp/xcape && make && sudo checkinstall


# dependencies for i3:
sudo apt-get install -y libxcb1-dev
sudo apt-get install -y libxcb-keysyms1-dev
sudo apt-get install -y libxcb-util0-dev
sudo apt-get install -y libxcb-icccm4-dev
sudo apt-get install -y libyajl-dev
sudo apt-get install -y libstartup-notification0-dev
sudo apt-get install -y libxcb-randr0-dev
sudo apt-get install -y libev-dev
sudo apt-get install -y libxcb-xinerama0-dev
sudo apt-get install -y libpango1.0-dev
sudo apt-get install -y libxcursor-dev
sudo apt-get install -y libxcb-cursor-dev
sudo apt-get install -y libxcb-xkb-dev
sudo apt-get install -y libxkbcommon-dev
sudo apt-get install -y libxkbcommon-x11-dev

sudo apt-get install -y i3status
sudo apt-get install -y suckless-tools

# passthrough install stuff:
sudo apt-get install -y qemu-kvm libvirt-bin ubuntu-vm-builder bridge-utils qemu-utils


# install docker goodness
curl -sSL https://get.docker.com/ | sh
sudo usermod -aG docker `whoami`

#docker-compose goodness
curl -L https://github.com/docker/compose/releases/download/1.5.2/docker-compose-`uname -s`-`uname -m` > docker-compose
sudo mv docker-compose /usr/local/bin/
sudo chmod +x /usr/local/bin/docker-compose
