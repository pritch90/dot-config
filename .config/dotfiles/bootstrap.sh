#!/bin/zsh

set -euo pipefail

repo_url="${DOTFILES_REPO_URL:-https://github.com/pritch90/dot-config.git}"
branch="${DOTFILES_BRANCH:-main}"
home="${HOME}"
cfg="${home}/.cfg"
git_cmd=(/usr/bin/git --git-dir="$cfg" --work-tree="$home")

fail() {
  print -u2 -- "bootstrap: $*"
  exit 1
}

require_apple_silicon_macos() {
  [[ "$(/usr/bin/uname -s)" == "Darwin" ]] || fail "this bootstrap supports macOS only"
  [[ "$(/usr/bin/uname -m)" == "arm64" ]] || fail "this bootstrap supports Apple Silicon only"
}

install_homebrew() {
  if [[ ! -x /opt/homebrew/bin/brew ]]; then
    /bin/bash -c "$(/usr/bin/curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  fi

  eval "$(/opt/homebrew/bin/brew shellenv)"
}

clone_or_update_repo() {
  if [[ ! -d "$cfg" ]]; then
    /usr/bin/git clone --bare "$repo_url" "$cfg"
  else
    "${git_cmd[@]}" remote set-url origin "$repo_url" || true
    "${git_cmd[@]}" fetch origin "$branch"
  fi

  "${git_cmd[@]}" config status.showUntrackedFiles no
}

tracked_ref() {
  if /usr/bin/git --git-dir="$cfg" rev-parse --verify --quiet "origin/$branch" >/dev/null; then
    print -- "origin/$branch"
  else
    print -- "$branch"
  fi
}

backup_conflicts() {
  local ref="$1"
  local backup_root="${home}/.dotfiles-backup"
  local stamp backup_dir path abs dest
  stamp="$(/bin/date +%Y%m%d-%H%M%S)"
  backup_dir="${backup_root}/bootstrap-${stamp}"

  while IFS= read -r path; do
    [[ -z "$path" ]] && continue
    abs="${home}/${path}"
    [[ -e "$abs" || -L "$abs" ]] || continue

    if /usr/bin/git --git-dir="$cfg" show "${ref}:${path}" 2>/dev/null | /usr/bin/cmp -s - "$abs"; then
      continue
    fi

    dest="${backup_dir}/${path}"
    /bin/mkdir -p "$(/usr/bin/dirname "$dest")"
    /bin/mv "$abs" "$dest"
  done < <(/usr/bin/git --git-dir="$cfg" ls-tree -r --name-only "$ref")

  if [[ -d "$backup_dir" ]]; then
    print -- "Backed up conflicting files to $backup_dir"
  fi
}

checkout_repo() {
  "${git_cmd[@]}" checkout "$branch"
}

main() {
  require_apple_silicon_macos
  install_homebrew
  clone_or_update_repo
  local ref
  ref="$(tracked_ref)"
  backup_conflicts "$ref"
  checkout_repo
  /bin/zsh "${home}/.config/dotfiles/install.sh"
}

main "$@"
