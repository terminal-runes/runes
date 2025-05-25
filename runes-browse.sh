#!/usr/bin/env bash

# Detect the real script location (even if symlinked)
script_path="$(readlink -f "$0")"
project_dir="$(dirname "$script_path")"
sheet_dir="$project_dir/sheets"

# Ask user for window mode
echo "Choose window style:"
echo "1) Borderless aesthetic"
echo "2) Windowed (movable)"
read -rp "Enter choice [1-2]: " style_choice

case $style_choice in
  2)
    config_file="$project_dir/config/alacritty/alacritty-windowed.toml"
    ;;
  *)
    config_file="$project_dir/config/alacritty/alacritty.toml"
    ;;
esac

# Select a cheatsheet interactively
if command -v fzf &> /dev/null; then
  selected=$(ls "$sheet_dir"/*.txt | fzf)
else
  echo "[!] fzf not found. Falling back to numbered menu."
  files=("$sheet_dir"/*.txt)
  PS3="Select a sheet: "
  select opt in "${files[@]}"; do
    selected="$opt"; break
  done
fi

# Launch runes with selected sheet and chosen config in background
if [ -n "$selected" ]; then
  nohup alacritty --config-file "$config_file" -e "$project_dir/runes.sh" "$selected" >/dev/null 2>&1 &
else
  echo "No sheet selected. Exiting."
  exit 1
fi
