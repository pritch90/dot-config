#!/bin/zsh
# Stack selection.
#
# Which language stacks this machine is set up for. The selection lives in
# $DOTFILES_STACKS_FILE (machine-local, gitignored) and is written by
# install.sh. The same file is read by install.sh, the rest of the zsh config,
# and Neovim, so all three stay in agreement.
#
# Sourced early in .zshrc because path.zsh and tools.zsh depend on it.

export DOTFILES_STACKS_FILE="${DOTFILES_STACKS_FILE:-$HOME/.config/dotfiles/stacks}"

# Every stack this repo knows about, in prompt order.
typeset -ga DOTFILES_KNOWN_STACKS=(java node web go python terraform)

# Stacks that pull in another stack. web runs its language servers on node.
typeset -gA DOTFILES_STACK_REQUIRES=(
  web node
)

typeset -ga DOTFILES_STACKS

dotfiles_load_stacks() {
  DOTFILES_STACKS=()

  # No selection recorded yet: assume everything, so a machine that has not
  # run the installer behaves exactly as it did before stacks existed.
  if [[ ! -r "$DOTFILES_STACKS_FILE" ]]; then
    DOTFILES_STACKS=("${DOTFILES_KNOWN_STACKS[@]}")
    return
  fi

  local line
  while IFS= read -r line || [[ -n "$line" ]]; do
    line="${line%%\#*}"
    line="${line//[[:space:]]/}"
    [[ -n "$line" ]] || continue
    (( ${DOTFILES_STACKS[(Ie)$line]} )) || DOTFILES_STACKS+=("$line")
  done < "$DOTFILES_STACKS_FILE"

  local stack required
  for stack in "${(k)DOTFILES_STACK_REQUIRES[@]}"; do
    required="${DOTFILES_STACK_REQUIRES[$stack]}"
    if (( ${DOTFILES_STACKS[(Ie)$stack]} )) && (( ! ${DOTFILES_STACKS[(Ie)$required]} )); then
      DOTFILES_STACKS+=("$required")
    fi
  done
}

# stack_enabled <name> -> true when the stack is selected on this machine.
stack_enabled() {
  (( ${DOTFILES_STACKS[(Ie)$1]} ))
}

dotfiles_load_stacks
