# Delete packages
echo "Deleting packages..."
sudo pacman -R --noconfirm vim mplayer totem alacritty gnome-maps gnome-software gnome-terminal htop

# Update system
echo "System updating..."
sudo pacman -Syu --noconfirm

# Install Packages
echo "Install packages..."
sudo pacman -S --noconfirm git neovim mpv telegram-desktop discord steam btop

# yay install packages
echo "Install yay packages..."
yay -S --noconfirm google-chrome v2rayn