export NVM_DIR="${NVM_DIR:-$HOME/.nvm}"

load_nvm() {
  if command -v nvm >/dev/null 2>&1; then
    return 0
  fi

  [[ -s "$NVM_DIR/nvm.sh" ]] && source "$NVM_DIR/nvm.sh"
}

if [[ -o interactive ]]; then
  autoload -Uz compinit
  compinit -C -d "${XDG_CACHE_HOME:-$HOME/.cache}/zcompdump"

  zstyle ':completion:*' matcher-list '' 'm:{a-zA-Z}={A-Za-z}' 'r:|=*' 'l:|=* r:|=*'

  # Load nvm eagerly so nvm, node, and node-based global CLIs (e.g. codex) are on PATH.
  load_nvm
  if [[ -s "$NVM_DIR/bash_completion" ]]; then
    autoload -Uz bashcompinit && bashcompinit
    source "$NVM_DIR/bash_completion"
  fi
fi

export SDKMAN_DIR="${SDKMAN_DIR:-$HOME/.sdkman}"
[[ -s "$SDKMAN_DIR/bin/sdkman-init.sh" ]] && source "$SDKMAN_DIR/bin/sdkman-init.sh"
