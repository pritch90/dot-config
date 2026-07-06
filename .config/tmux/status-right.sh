#!/bin/sh

set -u

spotify_script="$HOME/.config/dotfiles/scripts/spotify-status.sh"
battery_dir="$HOME/.tmux/plugins/tmux-battery/scripts"

spotify="$("$spotify_script" 2>/dev/null || true)"
battery_icon="$("$battery_dir/battery_icon.sh" 2>/dev/null || true)"
battery_percentage="$("$battery_dir/battery_percentage.sh" 2>/dev/null || true)"
battery_remain="$("$battery_dir/battery_remain.sh" 2>/dev/null || true)"
date_text="$(date '+%Y-%m-%d')"
time_text="$(date '+%H:%M')"

right_text="$(printf '%s  %s %s %s  %s %s' \
  "$spotify" \
  "$battery_icon" \
  "$battery_percentage" \
  "$battery_remain" \
  "$date_text" \
  "$time_text")"

visible_width() {
  LC_CTYPE=UTF-8 awk '{
    total += length($0)
  }
  END {
    print total + 0
  }'
}

case "${1:---plain}" in
  --width)
    printf '%s' "$right_text" | visible_width
    ;;
  --plain | "")
    printf '%s' "$right_text"
    ;;
esac
