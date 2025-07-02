# Delete packages
echo "Deleting packages..."
sudo pacman -R --noconfirm vim mplayer totem alacritty gnome-maps gnome-software gnome-terminal htop

# Update system
echo "System updating..."
sudo pacman -Syu --noconfirm

# Install Packages
echo "Install packages..."
sudo pacman -S --noconfirm git neovim mpv telegram-desktop discord steam btop curl perl

# yay install packages
echo "Install yay packages..."
yay -S --noconfirm google-chrome v2rayn

# mpv configurate
mkdir -p ~/.config/mpv/scripts
curl -L -o ~/.config/mpv/scripts/fuzzydir.lua https://github.com/sibwaf/mpv-scripts/blob/master/fuzzydir.lua
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