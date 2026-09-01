export DOTFILES_DIR="$HOME/.config/dotfiles"

[[ -x /opt/homebrew/bin/brew ]] && eval "$(/opt/homebrew/bin/brew shellenv)"

[[ -r "$DOTFILES_DIR/versions.env" ]] && source "$DOTFILES_DIR/versions.env"
[[ -r "$DOTFILES_DIR/local.env" ]] && source "$DOTFILES_DIR/local.env"

source "$HOME/.config/zsh/stacks.zsh"
source "$HOME/.config/zsh/path.zsh"
source "$HOME/.config/zsh/tools.zsh"
source "$HOME/.config/zsh/aliases.zsh"
source "$HOME/.config/zsh/functions.zsh"

[[ -r "$HOME/.config/zsh/local.zsh" ]] && source "$HOME/.config/zsh/local.zsh"
[[ -r "$HOME/.config/zsh/work.zsh" ]] && source "$HOME/.config/zsh/work.zsh"
[[ -r "$HOME/.config/zsh/secrets.zsh" ]] && source "$HOME/.config/zsh/secrets.zsh"

if [[ -o interactive ]] && command -v oh-my-posh >/dev/null 2>&1; then
  theme="$DOTFILES_DIR/themes/amro.omp.json"
  [[ -r "$theme" ]] && eval "$(oh-my-posh init zsh --config "$theme")"
fi
