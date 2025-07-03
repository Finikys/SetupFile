#!/usr/bin/env bash
set -e
trap 'echo "Oopsie! Error on line $LINENO — but Astolfo never gives up!"' ERR

echo "☆ Astolfo-chan, the eternally optimistic and mischievous paladin, here! 🌟"
while true; do
  read -r -p "Shall I sparkle your system with my magical dance and proceed? (y/n): " -n 1
  echo
  case $REPLY in
    [yY]) echo "Yay~ Let's ride the rainbow together! 🌈"; break ;;
    [nN]) echo "Aww, you’re not letting me perform… Maybe next time, senpai!"; exit 1 ;;
    *) echo "Hehe… press y or n, ok? ☆";;
  esac
done

echo "Deleting packages..."
PKGS=(mplayer totem alacritty gnome-maps gnome-software gnome-terminal htop)
for pkg in "${PKGS[@]}"; do
  if pacman -Q "$pkg" &>/dev/null; then
    sudo pacman -R --noconfirm "$pkg"
  else
    echo "Package '$pkg' not installed, skipping."
  fi
done

# Update system
echo "🔁 Updating system and installing packages…"
if ! sudo pacman -Syu --noconfirm; then
  echo "→ Conflicts detected. Retrying with auto-confirm…"
  yes | sudo pacman -Syu
fi

# Install packages
PACKAGES=(
  git mpv telegram-desktop discord steam btop curl perl qbittorrent
)

echo "📦 Installing official packages…"
sudo pacman -S --needed "${PACKAGES[@]}"


# Install AUR packages
if ! command -v yay &>/dev/null; then
    echo "Yay not found, installing..."
    sudo pacman -S --needed git base-devel
    git clone https://aur.archlinux.org/yay.git /tmp/yay
    cd /tmp/yay
    makepkg -si --noconfirm
    cd -
    rm -rf /tmp/yay
fi

AUR_PACKAGES=(google-chrome v2rayn)
echo "📦 Installing AUR packages…"
yay -S --noconfirm --needed "${AUR_PACKAGES[@]}"

# mpv configuration
mkdir -p ~/.config/mpv/scripts
curl -L -o ~/.config/mpv/scripts/fuzzydir.lua https://raw.githubusercontent.com/sibwaf/mpv-scripts/master/fuzzydir.lua

CONF_FILE=~/.config/mpv/mpv.conf

declare -A CONFIG_LINES=(
    ["keep-open"]="yes"
    ["audio-file-auto"]="fuzzy"
    ["audio-file-paths"]="**"
    ["sub-auto"]="fuzzy"
    ["sub-file-path"]="**"
    ["alang"]="ru,en,ja"
)

# Создаем файл, если не существует
touch "$CONF_FILE"

for key in "${!CONFIG_LINES[@]}"; do
    value="${CONFIG_LINES[$key]}"
    if grep -q "^$key=" "$CONF_FILE"; then
        # Заменяем строку
        sed -i "s|^$key=.*|$key=$value|" "$CONF_FILE"
    else
        # Добавляем новую строку
        echo "$key=$value" >> "$CONF_FILE"
    fi
done

echo "Everything is ready, enjoy!"
