#!/bin/zsh

set -euo pipefail

home="${HOME}"
cfg="${home}/.cfg"
backup_root="${home}/.dotfiles-backup"
git_cmd=(/usr/bin/git --git-dir="$cfg" --work-tree="$home")

fail() {
  print -u2 -- "restore: $*"
  exit 1
}

[[ -d "$cfg" ]] || fail "bare repo not found at $cfg"
[[ -d "$backup_root" ]] || fail "backup directory not found at $backup_root"

snapshot="${1:-}"
if [[ -z "$snapshot" ]]; then
  snapshots=("$backup_root"/*(N/om))
  snapshot="${snapshots[1]:-}"
else
  snapshot="${backup_root}/${snapshot}"
fi

[[ -d "$snapshot" ]] || fail "backup snapshot not found: $snapshot"

tracked=("${(@f)$("${git_cmd[@]}" ls-tree -r --name-only HEAD)}")
restore_paths=()

for path in "${tracked[@]}"; do
  if [[ -e "${snapshot}/${path}" || -L "${snapshot}/${path}" ]]; then
    restore_paths+=("$path")
  fi
done

(( ${#restore_paths[@]} > 0 )) || fail "snapshot contains no files tracked by the dotfiles repo"

print -- "Snapshot: $snapshot"
print -- "Files to restore:"
for path in "${restore_paths[@]}"; do
  print -- "  $path"
done

answer=""
read -r "answer?Restore these files? [y/N] "
answer="${answer:l}"
[[ "$answer" == "y" || "$answer" == "yes" ]] || fail "restore cancelled"

pre_restore="${backup_root}/pre-restore-$(/bin/date +%Y%m%d-%H%M%S)"

for path in "${restore_paths[@]}"; do
  current="${home}/${path}"
  parent="$(/usr/bin/dirname "$path")"
  if [[ -e "$current" || -L "$current" ]]; then
    /bin/mkdir -p "$pre_restore/$parent"
    /bin/cp -pR "$current" "${pre_restore}/${path}"
  fi

  /bin/mkdir -p "$(/usr/bin/dirname "$current")"
  /bin/cp -pR "${snapshot}/${path}" "$current"
done

print -- "Restored ${#restore_paths[@]} files."
print -- "Pre-restore backup: $pre_restore"
