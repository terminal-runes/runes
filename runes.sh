#!/usr/bin/env bash

# runes.sh - scrolls a cheatsheet in the terminal with style

# Use default sheet or user-supplied one
DEFAULT_SHEET="$(dirname "$0")/sheets/default.txt"
FILE="${1:-$DEFAULT_SHEET}"

# --- Security check: make sure it's a plain-text file
filetype=$(file -b --mime-type "$FILE")
if [[ "$filetype" != text/plain ]]; then
  echo "Error: '$FILE' is not a plain text file. Aborting."
  exit 1
fi

DELAY=0.8

# --- Hide cursor and restore on exit ---------------------------------------
cleanup() {
  tput cvvis        # show cursor again
  clear             # leave a clean terminal
}

# Run cleanup on any normal exit
trap cleanup EXIT
# Allow Ctrl+C (SIGINT) or SIGTERM to abort the loop cleanly
trap 'cleanup; exit 130' INT TERM

# Hide the cursor immediately so it never flashes
tput civis

# --- dynamic height (updates on every window resize) -----------------------
update_size() {
  H=$(tput lines)
  L=$(wc -l < "$FILE")
}
trap update_size SIGWINCH   # recalc when the pane is resized
update_size                 # set initial H & L

# --- main render loop ------------------------------------------------------
while true; do
  for ((i = 1; i <= L; i++)); do
    clear
    tail -n "+$i" "$FILE" | head -n "$H" | sed -E \
      -e 's/^# .*/\x1b[1;36m&\x1b[0m/' \
      -e 's/^\$ .*/\x1b[1;37m&\x1b[0m/' \
      -e 's/^> .*/\x1b[2m&\x1b[0m/'
    sleep "$DELAY"
  done
  update_size               # file might have grown, recalc L
  sleep "$DELAY"
done
