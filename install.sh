#!/usr/bin/env bash

set -e

INSTALL_DIR="$HOME/.local/bin"
CONFIG_DIR="$HOME/.config/alacritty"
SCRIPT_NAME="runes"
SCRIPT_ALT="runes-windowed"
BROWSER_SCRIPT="runes-browse"
TOML_PATH="$(pwd)/config/alacritty/alacritty.toml"
TOML_ALT_PATH="$(pwd)/config/alacritty/alacritty-windowed.toml"

# --- Check for Alacritty ---
if ! command -v alacritty &> /dev/null; then
  echo "[!] Alacritty not found."
  echo "Install it manually using your package manager:"
  echo "  sudo pacman -S alacritty     # Arch"
  echo "  sudo apt install alacritty   # Debian/Ubuntu"
  echo "  brew install alacritty       # macOS"
  exit 1
else
  echo "[✓] Alacritty found."
fi

# --- Ensure install dir exists ---
mkdir -p "$INSTALL_DIR"

# --- Create default launcher ---
LAUNCHER="$INSTALL_DIR/$SCRIPT_NAME"
echo "#!/usr/bin/env bash" > "$LAUNCHER"
echo "cd \"$(pwd)\" && nohup alacritty --config-file \"$TOML_PATH\" -e ./runes.sh \"\$@\" >/dev/null 2>&1 &" >> "$LAUNCHER"
chmod +x "$LAUNCHER"
echo "[✓] Installed launcher to $LAUNCHER"

# --- Create windowed config ---
cp "$TOML_PATH" "$TOML_ALT_PATH"
sed -i 's/decorations = \"none\"/decorations = \"full\"/' "$TOML_ALT_PATH"
echo "[✓] Created windowed config at $TOML_ALT_PATH"

# --- Create alternate launcher with window decorations ---
LAUNCHER_ALT="$INSTALL_DIR/$SCRIPT_ALT"
echo "#!/usr/bin/env bash" > "$LAUNCHER_ALT"
echo "cd \"$(pwd)\" && nohup alacritty --config-file \"$TOML_ALT_PATH\" -e ./runes.sh \"\$@\" >/dev/null 2>&1 &" >> "$LAUNCHER_ALT"
chmod +x "$LAUNCHER_ALT"
echo "[✓] Installed alternate launcher with window decorations as $LAUNCHER_ALT"

# --- Install interactive sheet browser ---
ln -sf "$(pwd)/runes-browse.sh" "$INSTALL_DIR/runes-browse"
chmod +x "$(pwd)/runes-browse.sh"
echo "[✓] Installed interactive sheet launcher as ~/.local/bin/runes-browse"

# --- Copy config to user home if they don't have one ---
if [ ! -f "$CONFIG_DIR/alacritty.toml" ]; then
  mkdir -p "$CONFIG_DIR"
  cp "$TOML_PATH" "$CONFIG_DIR/"
  echo "[✓] Copied default config to $CONFIG_DIR"
else
  echo "[→] Alacritty config already exists at $CONFIG_DIR, not overwritten."
fi

# --- Done ---
echo "[✓] Runes setup complete."
echo "Run 'runes' to launch with a transparent borderless window."
echo "Run 'runes-windowed' to launch with standard window decorations."
echo "Run 'runes-browse' to interactively choose a cheat sheet."
echo "💡 Tip: To move the borderless window, use your window manager's move shortcut."
echo "   Examples: Alt + Drag (Linux), Alt+F7 (XFCE), or Super + Drag (KDE/GNOME)"
