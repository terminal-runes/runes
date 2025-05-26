#!/usr/bin/env bash

# runes.sh ‒ scrolls a cheatsheet in the terminal with style
#
# ┏━━━━━━━━━━━━━━━━━━━━━━ LIVE CONTROLS ━━━━━━━━━━━━━━━━━━━━━━┓
#   p             ── pause / resume scrolling
#   +             ── speed up  (reduce delay)
#   -             ── slow down (increase delay)
#   q / Esc       ── quit immediately
#   Ctrl‑C        ── quit (handled via SIGINT trap)
# ┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛

# ── File selection ───────────────────────────────────────────
DEFAULT_SHEET="$(dirname "$0")/sheets/default.txt"
FILE="${1:-$DEFAULT_SHEET}"

# ── Security check ──────────────────────────────────────────
filetype=$(file -b --mime-type "$FILE")
if [[ "$filetype" != text/plain ]]; then
  echo "Error: '$FILE' is not a plain text file. Aborting."
  exit 1
fi

# ── Timing defaults (stored as integers in ms) ──────────────
DELAY_MS=800      # initial scroll delay     ( 0.8 s )
STEP_MS=100       # plus/minus key step size ( 0.1 s )
MIN_DELAY_MS=50   # fastest allowed delay    ( 0.05 s)

paused=0          # 0 = scrolling, 1 = paused

# ── Cleanup & traps ─────────────────────────────────────────
cleanup() {
  tput cvvis      # show cursor again
  clear           # leave a clean terminal
}
trap cleanup EXIT                     # normal exit
trap 'cleanup; exit 130' INT TERM     # Ctrl‑C / kill

# Hide the cursor right away
tput civis

# ── Dynamic height ──────────────────────────────────────────
update_size() {
  H=$(tput lines)            # current terminal height
  L=$(wc -l < "$FILE")      # total lines in the sheet
}
trap update_size SIGWINCH    # recalc when window is resized
update_size

# ── Helper: convert ms → fractional seconds for read -t ─────
ms_to_sec() { awk -v ms="$1" 'BEGIN { printf "%.3f", ms/1000 }'; }

# ── Main render loop ────────────────────────────────────────
while true; do
  i=1
  while (( i <= L )); do
    clear
    tail -n "+$i" "$FILE" | head -n "$H" | sed -E \
      -e 's/^# .*/\x1b[1;36m&\x1b[0m/' \
      -e 's/^\$ .*/\x1b[1;37m&\x1b[0m/' \
      -e 's/^> .*/\x1b[2m&\x1b[0m/'

    # Read one keystroke with timeout = current delay
    key=""
    read -rsn1 -t "$(ms_to_sec $DELAY_MS)" key
    case "$key" in
      p)                      # toggle pause / resume
        paused=$(( 1 - paused ))
        ;;
      +)                      # speed up (faster scroll)
        if (( DELAY_MS > MIN_DELAY_MS )); then
          (( DELAY_MS -= STEP_MS ))
        fi
        ;;
      -)                      # slow down (slower scroll)
        (( DELAY_MS += STEP_MS ))
        ;;
      q|$'\e')               # quit with q or Esc
        cleanup; exit 0
        ;;
    esac

    # Advance only when not paused
    if (( paused == 0 )); then
      (( i++ ))
    fi
  done
  update_size                 # file might have grown, recalc L
  # loop continues automatically
done
