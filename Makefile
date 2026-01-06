.PHONY: install configs deps install-hypr install-sway

deps:
	sudo pacman -S foot kitty git docker

install-hypr:
	sudo pacman -S hyprcursor hyprgraphics hypridle hyprland hyprland-guiutils \
		hyprland-qt-support hyprlang hyprlock hyprpaper hyprpolkitagent hyprtoolkit \
		hyprutils hyprwayland-scanner hyprwire xdg-desktop-portal-hyprland

install-sway:
	sudo pacman -S sway swaybg swayidle swaylock swayosd


configs:
	@command -v dotbot &> /dev/null || pipx install dotbot
	@mkdir -p ~/src
	@cd $(CURDIR) && \
		git clone https://github.com/tarjoilija/zgen.git "$(HOME)/src/zgen" || echo "already cloned"
	@git submodule update --init --recursive ~/dotfiles/vim/bundle/Vundle.vim
	@git submodule foreach -q --recursive 'branch="$$(git config -f ~/dotfiles/.gitmodules submodule.$$name.branch)"; git checkout $$branch master; git pull'
	@cd $(CURDIR) && dotbot -d "$(CURDIR)" -c install.conf.yaml $(ARGS)
	@vim +PluginInstall +qall
	# @fc-cache -vf ~/.fonts
