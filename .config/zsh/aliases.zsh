alias config='/usr/bin/git --git-dir=$HOME/.cfg/ --work-tree=$HOME'
alias grefresh="git refresh"
alias ip="curl 'https://api.ipify.org?format=json' -s | jq '.ip' | tr -d '\"'"
alias lg="lazygit"
alias p="pnpm"
alias t="tmuxinator"
alias uuidgen='uuidgen | tr "[:upper:]" "[:lower:]" | tr -d "\n"'
