#!/usr/bin/env bash
set -e
trap 'echo -e "${RED}Error on line $LINENO — aborting.${RESET}"' ERR

sudo pacman -S --needed --noconfirm git curl perl wget gcc clang 
bash -c "$(curl -s https://end-4.github.io/dots-hyprland-wiki/setup.sh)"

# ===== Colors =====
RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'
BLUE='\033[1;34m'; MAGENTA='\033[1;35m'; CYAN='\033[1;36m'
RESET='\033[0m'

say() {
    local COLOR=$1; shift
    echo -e "${COLOR}$*${RESET}"
}

say "$MAGENTA" "Starting the setup…"

# Confirmation
while true; do
    read -r -p "$(echo -e "${YELLOW}Proceed with installation and configuration? (y/n): ${RESET}")" -n 1
    echo
    case $REPLY in
        [yY]) say "$GREEN" "Proceeding..."; break ;;
        *) say "$RED" "Aborted."; exit 1 ;;
    esac
done

# ===== Remove unneeded packages =====
say "$BLUE" "Removing unnecessary packages..."
PKGS=(mplayer totem alacritty gnome-maps gnome-software gnome-terminal htop firefox-i18n-ru firefox illogical-impulse-kde dolphin)
for pkg in "${PKGS[@]}"; do
    if pacman -Q "$pkg" &>/dev/null; then
        sudo pacman -R --noconfirm "$pkg"
        say "$YELLOW" "Removed: $pkg"
    fi
done

# ===== Update and install base packages =====
say "$CYAN" "Updating system and installing essential tools..."
sudo pacman -Syu --noconfirm
PACKAGES=(git mpv telegram-desktop discord steam btop curl perl qbittorrent obsidian code tlp powertop jq)
sudo pacman -S --needed "${PACKAGES[@]}"

# ===== Installing yay and AUR packages =====
if ! command -v yay &>/dev/null; then
    say "$YELLOW" "Yay not found, installing..."
    sudo pacman -S --needed git base-devel
    git clone https://aur.archlinux.org/yay.git /tmp/yay
    cd /tmp/yay
    makepkg -si --noconfirm
    cd -
    rm -rf /tmp/yay
fi

AUR_PACKAGES=(google-chrome)
say "$GREEN" "Installing AUR packages…"
yay -S --noconfirm --needed "${AUR_PACKAGES[@]}"

# ===== Power management =====
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

# ===== Setting up mpv =====
say "$BLUE" "Configuring mpv settings..."

# Installing scripts
mkdir -p ~/.config/mpv/scripts

curl -sfL https://raw.githubusercontent.com/sibwaf/mpv-scripts/master/fuzzydir.lua \
     -o ~/.config/mpv/scripts/fuzzydir.lua || true

# Main config
CONF=~/.config/mpv/mpv.conf
mkdir -p "$(dirname "$CONF")"
touch "$CONF"

# Options: delete old ones, add in the desired order
for config in \
    "audio-file-auto=fuzzy" \
    "audio-file-paths=**" \
    "sub-auto=fuzzy" \
    "sub-file-paths=**" \
    "alang=ru,en,ja" \
    "directory-mode=recursive" \
    "autocreate-playlist=same" \
    "keep-open=yes"
do
    key="${config%%=*}"
    sed -i "/^${key}=/d" "$CONF"
    echo "$config" >> "$CONF"
done

say "$GREEN" "mpv configured: external audio fuzzy, субтитры fuzzy, рекурсивный плейлист и автозагрузка соседних файлов."
# ===== Configuring Russian keyboard layout for Hyprland =====
say "$MAGENTA" "Configuring Russian keyboard layout for Hyprland…"

HYPRCONF=~/.config/hypr/hyprland.conf
mkdir -p ~/.config/hypr
touch "$HYPRCONF"

# Let's check if there is an input section
if grep -q "^\s*input\s*{" "$HYPRCONF"; then
    # Remove old kb_layout and kb_options settings inside input
    sed -i '/^\s*input\s*{/,/}/ s/^\s*kb_layout\s*=.*/    kb_layout = us,ru/' "$HYPRCONF"
    sed -i '/^\s*input\s*{/,/}/ s/^\s*kb_options\s*=.*/    kb_options = grp:alt_shift_toggle/' "$HYPRCONF"

    # Add if they were not there
    if ! grep -Pzo "input\s*{[^}]*\bkb_layout\b" "$HYPRCONF" &>/dev/null; then
        sed -i '/^\s*input\s*{.*/a \    kb_layout = us,ru' "$HYPRCONF"
    fi
    if ! grep -Pzo "input\s*{[^}]*\bkb_options\b" "$HYPRCONF" &>/dev/null; then
        sed -i '/^\s*input\s*{.*/a \    kb_options = grp:alt_shift_toggle' "$HYPRCONF"
    fi
else
    # Let's add a new input section
    cat >> "$HYPRCONF" <<EOF

input {
    kb_layout = us,ru
    kb_variant =
    kb_options = grp:alt_shift_toggle
}
EOF
fi

say "$GREEN" "→ Russian layout configured! You can switch layouts with Alt+Shift."

# ===== Illogical-Impulse configuration settings =====

CONFIG="$HOME/.config/illogical-impulse/config.json"

if [[ ! -f "$CONFIG" ]]; then
  echo "The configuration file was not found: $CONFIG"
  exit 1
fi

cp "$CONFIG" "$CONFIG.bak"
echo "A reserve copy has been created: $CONFIG.bak"

jq '
  .dock.enable = true |
  .dock.pinnedApps = [
    "google-chrome",
    "org.telegram.desktop",
    "obsidian",
    "steam",
    "discord"
  ]
' "$CONFIG" > "$CONFIG.tmp" && mv "$CONFIG.tmp" "$CONFIG"

echo "The configuration is successfully updated."

# ===== Ending =====

say "$GREEN" "Setup complete. Please reboot system"
