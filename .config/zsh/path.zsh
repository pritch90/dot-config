path_prepend() {
  local dir="$1"
  [[ -d "$dir" ]] || return 0
  case ":$PATH:" in
    *":$dir:"*) ;;
    *) export PATH="$dir:$PATH" ;;
  esac
}

path_prepend "/opt/homebrew/bin"
path_prepend "/opt/homebrew/sbin"
path_prepend "$HOME/.local/bin"
path_prepend "$HOME/bin"
# Not stack-gated: holds cargo-installed CLI tools regardless of Rust dev.
path_prepend "$HOME/.cargo/bin"

stack_enabled go && path_prepend "$HOME/go/bin"

if stack_enabled node; then
  export PNPM_HOME="$HOME/Library/pnpm"
  path_prepend "$PNPM_HOME"
fi
