#!/usr/bin/env bash

set -u

MAX_LEN="${SPOTIFY_STATUS_MAX_LEN:-60}"

case "$MAX_LEN" in
  ''|*[!0-9]*)
    MAX_LEN=60
    ;;
esac

if [ "$MAX_LEN" -lt 2 ]; then
  MAX_LEN=60
fi

if ! command -v osascript >/dev/null 2>&1; then
  exit 0
fi

is_running="$(osascript -e 'application "Spotify" is running' 2>/dev/null)" || exit 0

if [ "$is_running" != "true" ]; then
  exit 0
fi

track="$(
  osascript 2>/dev/null <<'APPLESCRIPT'
tell application "Spotify"
  if player state is not playing then return ""
  set track_artist to artist of current track
  set track_name to name of current track
  return track_artist & " - " & track_name
end tell
APPLESCRIPT
)" || exit 0

if [ -z "$track" ]; then
  exit 0
fi

output="♪ $track"

if [ "${#output}" -gt "$MAX_LEN" ]; then
  output="${output:0:$((MAX_LEN - 1))}..."
fi

printf '%s\n' "$output"
