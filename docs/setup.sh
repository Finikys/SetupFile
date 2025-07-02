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

echo "System updating..."
sudo pacman -Syu --noconfirm

echo "Install packages..."
sudo pacman -S --noconfirm --needed git mpv telegram-desktop discord steam btop curl perl

# Установка yay из AUR, если не найден
if ! command -v yay &>/dev/null; then
    echo "Yay not found, installing..."
    sudo pacman -S --needed git base-devel
    git clone https://aur.archlinux.org/yay.git /tmp/yay
    cd /tmp/yay
    makepkg -si --noconfirm
    cd -
    rm -rf /tmp/yay
fi

echo "Install yay packages..."
yay -S --noconfirm --needed google-chrome v2rayn

# mpv configurate
mkdir -p ~/.config/mpv/scripts
curl -L -o ~/.config/mpv/scripts/fuzzydir.lua https://raw.githubusercontent.com/sibwaf/mpv-scripts/master/fuzzydir.lua
CONF_FILE=~/.config/mpv/mpv.conf

LINES_TO_ADD=(
    "keep-open=yes"
    "audio-file-auto=fuzzy"
    "audio-file-paths=**"
    "sub-auto=fuzzy"
    "sub-file-path=**"
    "alang=ru,en,ja"
)

for line in "${LINES_TO_ADD[@]}"; do
    if ! grep -Fxq "$line" "$CONF_FILE"; then
        echo "$line" >> "$CONF_FILE"
    fi
done

echo "Everything is ready, enjoy!"
