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

# Configuring Russian keyboard layout for Hyprland
say "$MAGENTA" "Configuring Russian keyboard layout for Hyprland…"

HYPRCONF=~/.config/hypr/hyprland.conf
mkdir -p ~/.config/hypr
touch "$HYPRCONF"

# Проверим, есть ли секция input
if grep -q "^\s*input\s*{" "$HYPRCONF"; then
    # Удаляем старые настройки kb_layout и kb_options внутри input
    sed -i '/^\s*input\s*{/,/}/ s/^\s*kb_layout\s*=.*/    kb_layout = us,ru/' "$HYPRCONF"
    sed -i '/^\s*input\s*{/,/}/ s/^\s*kb_options\s*=.*/    kb_options = grp:alt_shift_toggle/' "$HYPRCONF"

    # Добавляем если их не было
    if ! grep -Pzo "input\s*{[^}]*\bkb_layout\b" "$HYPRCONF" &>/dev/null; then
        sed -i '/^\s*input\s*{.*/a \    kb_layout = us,ru' "$HYPRCONF"
    fi
    if ! grep -Pzo "input\s*{[^}]*\bkb_options\b" "$HYPRCONF" &>/dev/null; then
        sed -i '/^\s*input\s*{.*/a \    kb_options = grp:alt_shift_toggle' "$HYPRCONF"
    fi
else
    # Добавим новую секцию input
    cat >> "$HYPRCONF" <<EOF

# Added by Astolfo's setup script ✨
input {
    kb_layout = us,ru
    kb_variant =
    kb_options = grp:alt_shift_toggle
}
EOF
fi

say "$GREEN" "→ Russian layout configured! You can switch layouts with Alt+Shift."

# Configure nwg-dock-hyprland
say "$BLUE" "Configuring nwg-dock-hyprland..."
HYPR=~/.config/hypr/hyprland.conf
mkdir -p ~/.config/hypr
grep -q "exec-once =.*nwg-dock-hyprland" "$HYPR" 2>/dev/null || cat >> "$HYPR" <<EOF

# nwg‑dock: visible on all monitors, larger hot‑zone, pinned apps only
exec-once = sleep 5 && nwg-dock-hyprland \
  -d \
  -p bottom \
  -i 48 \
  -mb 10 -ml 10 -mr 10 -mt 10 \
  -x \
  -hd 200 \
  -nolauncher \
  -c "nautilus" \
  -c "google-chrome-stable" \
  -c "telegram-desktop" \
  -c "obsidian" \
  -c "steam" \
  -c "discord"
EOF

# ===== 🖥️ Настройка разрешения экрана =====
say "$CYAN" "Configure screen resolution? (you can skip or choose a common resolution)"

PS3="Select resolution (or 'skip'): "
options=("1920x1080@60" "1280x720@60" "Skip")
select opt in "${options[@]}"; do
  case $opt in
    "1920x1080@60")
      RES="1920x1080@60"
      say "$GREEN" "Selected resolution: $RES"
      break
      ;;
    "1280x720@60")
      RES="1280x720@60"
      say "$GREEN" "Selected resolution: $RES"
      break
      ;;
    "Skip")
      say "$YELLOW" "Skipping resolution configuration"
      RES=""
      break
      ;;
    *) say "$YELLOW" "Invalid option";;
  esac
done

if [ -n "$RES" ]; then
  HYPR=~/.config/hypr/hyprland.conf
  mkdir -p "$(dirname "$HYPR")"

  if grep -q "^monitor=" "$HYPR"; then
    sed -i "s/^monitor=.*/monitor=auto,${RES},0x0,1/" "$HYPR"
  else
    echo -e "\n# Automatically set resolution\nmonitor=auto,${RES},0x0,1" >> "$HYPR"
  fi

  say "$GREEN" "Resolution set in hyprland.conf: ${RES}"
  say "$YELLOW" "Please run 'hyprctl reload' or restart Hyprland to apply."
fi


say "$GREEN" "Setup complete. Please reload Hyprland to apply nwg-dock settings."
