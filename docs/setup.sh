#!/usr/bin/env bash
set -e
trap 'echo -e "${RED}Oopsie! Error on line $LINENO — but Astolfo never gives up!${RESET}"' ERR

# ===== 🎨 Цвета =====
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[1;34m'
MAGENTA='\033[1;35m'
CYAN='\033[1;36m'
BOLD='\033[1m'
RESET='\033[0m'

say() {
    local COLOR=$1
    shift
    echo -e "${COLOR}$*${RESET}"
}

# ===== 🌟 Приветствие =====
say "$MAGENTA" "☆ Astolfo-chan, the eternally optimistic and mischievous paladin, here! 🌟"

while true; do
  read -r -p "$(echo -e "${YELLOW}Shall I sparkle your system with my magical dance and proceed? (y/n): ${RESET}")" -n 1
  echo
  case $REPLY in
    [yY]) say "$GREEN" "Yay~ Let's ride the rainbow together! 🌈"; break ;;
    [nN]) say "$RED" "Aww, you’re not letting me perform… Maybe next time, senpai!"; exit 1 ;;
    *) say "$YELLOW" "Hehe… press y or n, ok? ☆";;
  esac
done

# ===== ❌ Удаление пакетов =====
say "$RED" "Removing unnecessary packages..."
PKGS=(mplayer totem alacritty gnome-maps gnome-software gnome-terminal htop firefox-i18n-ru firefox)
for pkg in "${PKGS[@]}"; do
  if pacman -Q "$pkg" &>/dev/null; then
    sudo pacman -R --noconfirm "$pkg"
    say "$YELLOW" "→ Removed $pkg"
  else
    say "$BLUE" "→ Package '$pkg' not installed, skipping."
  fi
done

# ===== 🔁 Обновление системы =====
say "$CYAN" "🔁 Updating system and installing packages…"
if ! sudo pacman -Syu --noconfirm; then
  say "$YELLOW" "→ Conflicts detected. Retrying with auto-confirm…"
  yes | sudo pacman -Syu
fi

# ===== 📦 Установка официальных пакетов =====
PACKAGES=(git mpv telegram-desktop discord steam btop curl perl qbittorrent obsidian code)
say "$GREEN" "📦 Installing official packages…"
sudo pacman -S "${PACKAGES[@]}"

# ===== 🚀 Установка yay и AUR-пакетов =====
if ! command -v yay &>/dev/null; then
    say "$YELLOW" "Yay not found, installing..."
    sudo pacman -S --needed git base-devel
    git clone https://aur.archlinux.org/yay.git /tmp/yay
    cd /tmp/yay
    makepkg -si --noconfirm
    cd -
    rm -rf /tmp/yay
fi

AUR_PACKAGES=(google-chrome byedpi)
say "$GREEN" "📦 Installing AUR packages…"
yay -S --noconfirm --needed "${AUR_PACKAGES[@]}"

# ===== 🎞️ Настройка mpv =====
say "$MAGENTA" "🎞️ Configuring MPV…"
mkdir -p ~/.config/mpv/scripts
curl -L -o ~/.config/mpv/scripts/fuzzydir.lua https://raw.githubusercontent.com/sibwaf/mpv-scripts/master/fuzzydir.lua

CONF_FILE=~/.config/mpv/mpv.conf
touch "$CONF_FILE"

declare -A CONFIG_LINES=(
    ["keep-open"]="yes"
    ["audio-file-auto"]="fuzzy"
    ["audio-file-paths"]="**"
    ["sub-auto"]="fuzzy"
    ["sub-file-paths"]="**"
    ["alang"]="ru,en,ja"
)

for key in "${!CONFIG_LINES[@]}"; do
    value="${CONFIG_LINES[$key]}"
    if grep -q "^$key=" "$CONF_FILE"; then
        sed -i "s|^$key=.*|$key=$value|" "$CONF_FILE"
        say "$CYAN" "→ Updated $key=$value"
    else
        echo "$key=$value" >> "$CONF_FILE"
        say "$CYAN" "→ Added $key=$value"
    fi
done

# ===== ⌨️ Настройка русской раскладки для Hyprland =====
say "$MAGENTA" "⌨️ Configuring Russian keyboard layout for Hyprland…"

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

# ===== 🎉 Финал =====
say "$GREEN" "✨ Everything is ready, enjoy your sparkly system, master~!"