#!/bin/zsh

set -euo pipefail

home="${HOME}"
cfg="${home}/.cfg"
git_cmd=(/usr/bin/git --git-dir="$cfg" --work-tree="$home")

[[ -d "$cfg" ]] || {
  print -u2 -- "doctor: bare repo not found at $cfg"
  exit 1
}

patterns=(
  'JFROG'
  'MONY'
  'moneysupermarket'
  'github_pat_'
  'AWS_SECRET_ACCESS_KEY'
  'AWS_SESSION_TOKEN'
  'BEGIN PRIVATE KEY'
  'CORTEX_API_TOKEN'
  'Zscaler'
)

failed=0
for pattern in "${patterns[@]}"; do
  if "${git_cmd[@]}" grep -nI -E "$pattern" -- . ':(exclude).config/dotfiles/doctor.sh'; then
    failed=1
  fi
done

if (( failed )); then
  print -u2 -- "doctor: public-safety denylist matched tracked files"
  exit 1
fi

print -- "doctor: no denylist matches in tracked files"
