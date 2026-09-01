#!/bin/zsh
#
# macOS system defaults.
#
# These are the settings this setup actually changes from Apple's defaults,
# captured from a configured machine. Anything not listed here is deliberately
# left at the system default.
#
# Safe to re-run. Run standalone with:
#   zsh ~/.config/dotfiles/macos.sh

set -euo pipefail

print -- "macos: applying system defaults"

# --- Dock ------------------------------------------------------------------
# Left-hand dock, hidden until needed, slightly smaller than stock.
defaults write com.apple.dock autohide -bool true
defaults write com.apple.dock orientation -string "left"
defaults write com.apple.dock tilesize -int 57

# --- Finder ----------------------------------------------------------------
# Column view by default, with the status bar showing item counts and space.
defaults write com.apple.finder FXPreferredViewStyle -string "clmv"
defaults write com.apple.finder ShowStatusBar -bool true

# --- Trackpad --------------------------------------------------------------
# Tap to click, for both the built-in and any Magic Trackpad.
defaults write com.apple.AppleMultitouchTrackpad Clicking -bool true
defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad Clicking -bool true
defaults -currentHost write NSGlobalDomain com.apple.mouse.tapBehavior -int 1
defaults write NSGlobalDomain com.apple.mouse.tapBehavior -int 1

# --- Apply -----------------------------------------------------------------
# Restart the affected apps so the changes take without a logout. Finder and
# Dock both relaunch themselves.
for app in Dock Finder; do
  /usr/bin/killall "$app" >/dev/null 2>&1 || true
done

print -- "macos: done (some changes need a logout to fully apply)"
