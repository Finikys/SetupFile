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
  ] |
  .bar.utilButtons = {
    showColorPicker: true,
    showDarkModeToggle: false,
    showKeyboardToggle: false,
    showMicToggle: false,
    showScreenSnip: false
  }
' "$CONFIG" > "$CONFIG.tmp" && mv "$CONFIG.tmp" "$CONFIG"

echo "The configuration is successfully updated."

sudo systemctl disable illogical-impulse-autostart.service
sudo rm /etc/systemd/system/illogical-impulse-autostart.service
sudo systemctl daemon-reload