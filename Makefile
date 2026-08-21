.PHONY: install configs deps install-hypr install-sway install-yay langservers langservers-php parsers parsers-force

# everything a fresh machine needs, in order
install: configs langservers langservers-php parsers

# base-devel (cc) and tree-sitter-cli build the treesitter parsers, which are host-compiled, not dockerable.
# tree-sitter-cli must come from pacman, NOT npm: upstream only supports the former.
deps:
	sudo pacman -S foot git docker neovim fuzzel base-devel tree-sitter-cli curl ripgrep

langservers:
	docker build -t dotfiles/langservers $(CURDIR)/vim/langservers

langservers-php:
	docker build -t dotfiles/langservers-php $(CURDIR)/vim/langservers/php

# list lives in vim/lua/ts_parsers.lua. Also clones missing plugins on the way, since vim.pack does that at startup.
parsers:
	nvim --headless \
		-c "lua require('nvim-treesitter').install(require('ts_parsers')):wait(600000)" \
		-c 'qa!'

# `make parsers` counts a lang installed if site/queries/<lang>/ exists, so it will not repair a deleted or corrupt .so.
parsers-force:
	nvim --headless \
		-c "lua require('nvim-treesitter').install(require('ts_parsers'), {force=true}):wait(600000)" \
		-c 'qa!'

install-hypr:
	sudo pacman -S hyprcursor hyprgraphics hypridle hyprland hyprland-guiutils \
	hyprland-qt-support hyprlang hyprlock hyprpaper hyprpolkitagent hyprtoolkit \
	hyprutils hyprwayland-scanner hyprwire xdg-desktop-portal-hyprland

install-sway:
	sudo pacman -S sway swaybg swayidle swaylock swayosd

install-yay:
	sudo pacman -S --needed base-devel git
	git clone https://aur.archlinux.org/yay-bin.git /tmp/yay-bin
	cd /tmp/yay-bin && makepkg -si
	rm -rf /tmp/yay-bin

zgen:
	@mkdir -p ~/src
	@cd $(CURDIR) && \
		git clone https://github.com/tarjoilija/zgen.git "$(HOME)/src/zgen" || echo "already cloned"

configs:
	@PATH="$$HOME/.local/bin:$$PATH" command -v dotbot &> /dev/null || pipx install dotbot
	@cd $(CURDIR) && PATH="$$HOME/.local/bin:$$PATH" dotbot -d "$(CURDIR)" -c install.conf.yaml $(ARGS)

fix-hyp:
	hyprpm purge-cache
	hyprpm update
	hyprpm add https://github.com/outfoxxed/hy3
	hyprpm enable hy3
