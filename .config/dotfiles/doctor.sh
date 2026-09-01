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

self='.config/dotfiles/doctor.sh'

# Pathspecs are ':(top)'-prefixed so they resolve against the work tree rather
# than the current directory. Without that, running from anywhere other than
# $HOME silently scans nothing and every check "passes".
failed=0
for pattern in "${patterns[@]}"; do
  if "${git_cmd[@]}" grep -nI -E -- "$pattern" ":(top)" ":(top,exclude)$self"; then
    failed=1
  fi
done

# git grep only reads file contents, so a path that names the employer would
# slip through. Check tracked paths too.
matches="$("${git_cmd[@]}" ls-files -- ":(top)" | /usr/bin/grep -i -E 'MONY|moneysupermarket' || true)"
if [[ -n "$matches" ]]; then
  print -r -- "$matches"
  failed=1
fi

if (( failed )); then
  print -u2 -- "doctor: public-safety denylist matched tracked files"
  exit 1
fi

print -- "doctor: no denylist matches in tracked files"
