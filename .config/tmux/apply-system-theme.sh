#!/bin/sh

set -u

tmux_bin="${TMUX_BIN:-tmux}"
theme_script="${TMUX_SYSTEM_THEME_SCRIPT:-$HOME/.config/tmux/apply-system-theme.sh}"
status_right_script="$HOME/.config/tmux/status-right.sh"
spotify_status="#($HOME/.config/dotfiles/scripts/spotify-status.sh 2>/dev/null)"
battery_dir="$HOME/.tmux/plugins/tmux-battery/scripts"
battery_icon="#($battery_dir/battery_icon.sh 2>/dev/null)"
battery_percentage="#($battery_dir/battery_percentage.sh 2>/dev/null)"
battery_remain="#($battery_dir/battery_remain.sh 2>/dev/null)"

if defaults read -g AppleInterfaceStyle 2>/dev/null | grep -q "Dark"; then
  mode="dark"
else
  mode="light"
fi

case "$mode" in
  dark)
    colorfgbg="15;0"
    bg="#282a36"
    fg="#eff0eb"
    muted="#686868"
    accent="#9aedfe"
    active_bg="#9aedfe"
    active_fg="#282a36"
    date_fg="#5af78e"
    time_fg="#f3f99d"
    activity_fg="#ff5c57"
    battery_bg="#5af78e"
    battery_fg="#282a36"
    selection_bg="#92bcd0"
    selection_fg="#000000"
    ;;
  *)
    colorfgbg="0;15"
    bg="#ffffff"
    fg="#262626"
    muted="#b3b3b3"
    accent="#135cd0"
    active_bg="#135cd0"
    active_fg="#ffffff"
    date_fg="#328a5d"
    time_fg="#fa701d"
    activity_fg="#f8282a"
    battery_bg="#328a5d"
    battery_fg="#ffffff"
    selection_bg="#6fd3fc"
    selection_fg="#041730"
    ;;
esac

run_tmux() {
  "$tmux_bin" "$@" >/dev/null 2>&1 || exit 0
}

visible_width() {
  LC_CTYPE=UTF-8 awk '{
    total += length($0)
  }
  END {
    print total + 0
  }'
}

repeat_spaces() {
  count="$1"
  [ "$count" -le 0 ] && return
  awk -v count="$count" 'BEGIN {
    for (i = 0; i < count; i++) {
      printf " "
    }
  }'
}

session_name="$("$tmux_bin" display-message -p '#S' 2>/dev/null || true)"
right_width="$("$status_right_script" --width 2>/dev/null || printf '0')"
left_width="$(printf '%s' "$session_name" | visible_width)"
pad_width=$((right_width - left_width))
[ "$pad_width" -lt 0 ] && pad_width=0
left_padding="$(repeat_spaces "$pad_width")"

run_tmux set-option -gq @system_theme_mode "$mode"
run_tmux set-environment -g COLORFGBG "$colorfgbg"
run_tmux set-option -gq status-style "fg=$fg,bg=$bg,bold"
run_tmux set-option -gq status-bg "$bg"
run_tmux set-option -gq status-fg "$fg"
run_tmux set-option -gq @batt_color_status_primary_charged "$battery_bg"
run_tmux set-option -gq @batt_color_status_primary_charging "$battery_bg"
run_tmux set-option -gq @batt_color_status_primary_discharging "$battery_bg"
run_tmux set-option -gq @batt_color_charge_primary_tier8 "$battery_bg"
run_tmux set-option -gq @batt_color_charge_primary_tier7 "$battery_bg"
run_tmux set-option -gq status-left "#[fg=$accent,bg=$bg]#S#[fg=$fg,bg=$bg]$left_padding"
run_tmux set-option -gq status-right "#($theme_script --quiet)#[fg=$fg,bg=$bg]$spotify_status#[fg=$muted,bg=$bg]  #[fg=$battery_fg,bg=$battery_bg] $battery_icon $battery_percentage $battery_remain #[fg=$date_fg,bg=$bg]  %Y-%m-%d #[fg=$time_fg,bg=$bg]%H:%M #[fg=$fg,bg=$bg]"

run_tmux set-window-option -gq window-status-format " #I - #W "
run_tmux set-window-option -gq window-status-current-format " #I - #W "
run_tmux set-window-option -gq window-status-style "fg=$fg,bg=$bg"
run_tmux set-window-option -gq window-status-current-style "fg=$active_fg,bg=$active_bg,bold"
run_tmux set-window-option -gq window-status-separator ""
run_tmux set-window-option -gq window-status-activity-style "fg=$activity_fg,bold"

run_tmux set-option -gq pane-border-style "fg=$muted,bg=$bg"
run_tmux set-option -gq pane-active-border-style "fg=$accent,bg=$bg"
run_tmux set-option -gq pane-border-status top
run_tmux set-option -gq pane-border-format " #{pane_index}: #{?pane_active,#[underscore],}#{?pane_title,#{pane_title},#{pane_current_command}}#{?pane_active,#[nounderscore],} "
run_tmux set-option -gq mode-style "fg=$selection_fg,bg=$selection_bg,bold"
run_tmux set-option -gq message-style "fg=$accent,bg=$bg,align=centre"
run_tmux set-option -gq message-command-style "fg=$selection_fg,bg=$selection_bg"
run_tmux set-option -gq menu-selected-style "fg=$selection_fg,bg=$selection_bg,bold"
