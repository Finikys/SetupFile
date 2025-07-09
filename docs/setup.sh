#!/usr/bin/env bash
set -e
trap 'echo -e "${RED}Error on line $LINENO — aborting.${RESET}"' ERR

# ===== Colors =====
RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'
BLUE='\033[1;34m'; MAGENTA='\033[1;35m'; CYAN='\033[1;36m'
RESET='\033[0m'

say() {
    local COLOR=$1; shift
    echo -e "${COLOR}$*${RESET}"
}

say "$MAGENTA" "Astolfo-chan: starting the setup…"

# Confirmation
while true; do
    read -r -p "$(echo -e "${YELLOW}Proceed with installation and configuration? (y/n): ${RESET}")" -n 1
    echo
    case $REPLY in
        [yY]) say "$GREEN" "Proceeding..."; break ;;
        *) say "$RED" "Aborted."; exit 1 ;;
    esac
done

# Remove unneeded packages
say "$BLUE" "Removing unnecessary packages..."
PKGS=(mplayer totem alacritty gnome-maps gnome-software gnome-terminal htop firefox-i18n-ru firefox illogical-impulse-kde dolphin)
for pkg in "${PKGS[@]}"; do
    if pacman -Q "$pkg" &>/dev/null; then
        sudo pacman -R --noconfirm "$pkg"
        say "$YELLOW" "Removed: $pkg"
    fi
done

# Update and install base packages
say "$CYAN" "Updating system and installing essential tools..."
sudo pacman -Syu --noconfirm
PACKAGES=(git mpv telegram-desktop discord steam btop curl perl qbittorrent obsidian code tlp powertop nwg-dock-hyprland)
sudo pacman -S --needed "${PACKAGES[@]}"

# Power management
say "$BLUE" "Configuring power management..."
sudo systemctl enable tlp --now
sudo systemctl mask power-profiles-daemon
sudo powertop --auto-tune
sudo tee /etc/systemd/system/powertop.service > /dev/null <<EOF
[Unit]
Description=Powertop tuning
After=multi-user.target

[Service]
Type=oneshot
ExecStart=/usr/bin/powertop --auto-tune

[Install]
WantedBy=multi-user.target
EOF
sudo systemctl daemon-reload
sudo systemctl enable powertop.service

# Configure mpv
say "$BLUE" "Configuring mpv settings..."
mkdir -p ~/.config/mpv/scripts
curl -sfL https://raw.githubusercontent.com/sibwaf/mpv-scripts/master/fuzzydir.lua \
     -o ~/.config/mpv/scripts/fuzzydir.lua || true

CONF=~/.config/mpv/mpv.conf
mkdir -p "$(dirname "$CONF")"; touch "$CONF"
declare -A mpv_conf=(
  [keep-open]=yes
  [audio-file-auto]=fuzzy
  [sub-auto]=fuzzy
  [alang]=ru,en,ja
)
for k in "${!mpv_conf[@]}"; do
  v=${mpv_conf[$k]}
  grep -q "^$k=" "$CONF" && \
    sed -i "s|^$k=.*|$k=$v|" "$CONF" || \
    echo "$k=$v" >> "$CONF"
done

say "$BLUE" "Configuring mpv keybindings..."
INPUT=~/.config/mpv/input.conf
mkdir -p "$(dirname "$INPUT")"
cat >> "$INPUT" <<EOF

# Left/Right – chapter navigation
Left add chapter -1
Right add chapter 1

# Up/Down – playlist navigation
Up playlist-next
Down playlist-prev

# Shift+Left/Right – seek ±85 seconds
Shift+Left seek -85
Shift+Right seek 85
EOF

# Configure nwg-dock-hyprland
say "$BLUE" "Configuring nwg-dock-hyprland..."
HYPR=~/.config/hypr/hyprland.conf
mkdir -p ~/.config/hypr
grep -q "exec-once =.*nwg-dock-hyprland" "$HYPR" 2>/dev/null || cat >> "$HYPR" <<EOF

# launch nwg-dock on all monitors, pinned apps only
exec-once = sleep 5 && nwg-dock-hyprland -d -p bottom -i 48 -mb 10 -ml 10 -mr 10 -mt 10 -x -nolauncher \
  -c "nautilus" \
  -c "google-chrome-stable" \
  -c "telegram-desktop" \
  -c "obsidian" \
  -c "steam" \
  -c "discord"
EOF

say "$GREEN" "Setup complete. Please reload Hyprland to apply nwg-dock settings."
