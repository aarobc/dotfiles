.PHONY: install configs deps install-hypr install-sway install-yay

deps: install-yay
	sudo pacman -S foot git docker neovim fuzzel

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

configs:
	@command -v dotbot &> /dev/null || pipx install dotbot
	@mkdir -p ~/src
	@cd $(CURDIR) && \
		git clone https://github.com/tarjoilija/zgen.git "$(HOME)/src/zgen" || echo "already cloned"
	@cd $(CURDIR) && dotbot -d "$(CURDIR)" -c install.conf.yaml $(ARGS)

fix-hyp:
	hyprpm purge-cache
	hyprpm update
	hyprpm add https://github.com/outfoxxed/hy3
	hyprpm enable hy3
