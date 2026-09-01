#!/bin/zsh

set -euo pipefail

dotfiles_dir="${HOME}/.config/dotfiles"
local_env="${dotfiles_dir}/local.env"
install_env="${dotfiles_dir}/install.local.env"
core_brewfile="${dotfiles_dir}/Brewfile.core"
qol_brewfile="${dotfiles_dir}/Brewfile.qol"
optional_brewfile="${dotfiles_dir}/Brewfile.optional"

# Set by --minimal; skips the quality-of-life app tier.
minimal=0

# Set by --stacks; skips the interactive stack prompt.
stacks_override=""

source "${dotfiles_dir}/versions.env"
[[ -r "$local_env" ]] && source "$local_env"

# Stack selection: DOTFILES_KNOWN_STACKS, DOTFILES_STACKS, stack_enabled().
source "${HOME}/.config/zsh/stacks.zsh"

fail() {
  print -u2 -- "install: $*"
  exit 1
}

confirm() {
  local prompt="$1"
  local default="${2:-n}"
  local suffix="[y/N]"
  [[ "$default" == "y" ]] && suffix="[Y/n]"

  local answer
  read -r "answer?$prompt $suffix "
  answer="${answer:l}"

  if [[ -z "$answer" ]]; then
    [[ "$default" == "y" ]]
  else
    [[ "$answer" == "y" || "$answer" == "yes" ]]
  fi
}

parse_args() {
  while (( $# )); do
    case "$1" in
      --minimal)
        minimal=1
        ;;
      --stacks)
        (( $# >= 2 )) || fail "--stacks needs a value, e.g. --stacks java,node"
        stacks_override="$2"
        shift
        ;;
      --stacks=*)
        stacks_override="${1#--stacks=}"
        ;;
      -h|--help)
        print -- "usage: install.sh [--minimal] [--stacks a,b,c]"
        print -- ""
        print -- "  --minimal       skip the quality-of-life app tier (Brewfile.qol)"
        print -- "  --stacks a,b,c  set language stacks non-interactively"
        print -- ""
        print -- "known stacks: ${DOTFILES_KNOWN_STACKS[*]}"
        exit 0
        ;;
      *)
        fail "unknown option: $1"
        ;;
    esac
    shift
  done
}

ensure_platform() {
  [[ "$(/usr/bin/uname -s)" == "Darwin" ]] || fail "macOS only"
  [[ "$(/usr/bin/uname -m)" == "arm64" ]] || fail "Apple Silicon only"
  [[ -x /opt/homebrew/bin/brew ]] || fail "Homebrew is required at /opt/homebrew/bin/brew"
  eval "$(/opt/homebrew/bin/brew shellenv)"
}

load_saved_choices() {
  if [[ -r "$install_env" ]]; then
    source "$install_env"
  fi
}

write_stacks_file() {
  local -a chosen
  chosen=("$@")

  /bin/mkdir -p "$dotfiles_dir"
  {
    print -- "# Language stacks enabled on this machine."
    print -- "# One per line. Edit and restart your shell, or re-run install.sh."
    print -- "# Known stacks: ${DOTFILES_KNOWN_STACKS[*]}"
    local stack
    for stack in "${chosen[@]}"; do
      print -- "$stack"
    done
  } >| "$DOTFILES_STACKS_FILE"

  # Re-read so the rest of this run sees the new selection, including any
  # implied stacks (web pulls in node).
  dotfiles_load_stacks
}

prompt_stacks() {
  local -a chosen
  chosen=()
  local stack

  if [[ -n "$stacks_override" ]]; then
    chosen=(${(s:,:)stacks_override})
    for stack in "${chosen[@]}"; do
      (( ${DOTFILES_KNOWN_STACKS[(Ie)$stack]} )) \
        || fail "unknown stack: $stack (known: ${DOTFILES_KNOWN_STACKS[*]})"
    done
    write_stacks_file "${chosen[@]}"
    print -- "install: stacks set to ${DOTFILES_STACKS[*]}"
    return
  fi

  if [[ -r "$DOTFILES_STACKS_FILE" ]]; then
    print -- "Saved stacks: ${DOTFILES_STACKS[*]}"
    if confirm "Reuse saved stack selection?" "y"; then
      return
    fi
  fi

  print -- "Select the language stacks for this machine."
  for stack in "${DOTFILES_KNOWN_STACKS[@]}"; do
    if confirm "  Enable the ${stack} stack?" "n"; then
      chosen+=("$stack")
    fi
  done

  write_stacks_file "${chosen[@]}"
  print -- "install: stacks set to ${DOTFILES_STACKS[*]}"
}

prompt_optional_tools() {
  local reuse_saved="n"
  if [[ -n "${DOTFILES_OPTIONAL_TOOLS:-}" ]]; then
    print -- "Saved optional tools: ${DOTFILES_OPTIONAL_TOOLS}"
    confirm "Reuse saved optional tool choices?" "y" && reuse_saved="y"
  fi

  if [[ "$reuse_saved" == "y" ]]; then
    return
  fi

  local selected=()
  local option prompt
  local options=(
    codex_app:"Install Codex app?"
    codex_tui:"Install Codex TUI?"
    claude_desktop:"Install Claude desktop?"
    claude_code:"Install Claude Code?"
    copilot_app:"Install GitHub Copilot app?"
    copilot_cli:"Install GitHub Copilot CLI?"
    intellij:"Install IntelliJ IDEA Ultimate?"
    awscli:"Install AWS CLI?"
    aws_vault:"Install aws-vault?"
    mongosh:"Install MongoDB Shell?"
    vscode:"Install VS Code?"
  )

  for entry in "${options[@]}"; do
    option="${entry%%:*}"
    prompt="${entry#*:}"
    if confirm "$prompt" "n"; then
      selected+=("$option")
    fi
  done

  export DOTFILES_OPTIONAL_TOOLS="${(j: :)selected}"
}

prompt_ai_cli() {
  local choices=()
  [[ " ${DOTFILES_OPTIONAL_TOOLS:-} " == *" codex_tui "* ]] && choices+=("codex")
  [[ " ${DOTFILES_OPTIONAL_TOOLS:-} " == *" claude_code "* ]] && choices+=("claude")
  [[ " ${DOTFILES_OPTIONAL_TOOLS:-} " == *" copilot_cli "* ]] && choices+=("copilot")
  choices+=("none")

  local default="${DOTFILES_AI_CLI:-${choices[1]}}"
  local answer
  print -- "AI CLI options for tmuxinator dev pane: ${(j:, :)choices}"
  read -r "answer?AI CLI command [$default] "
  answer="${answer:-$default}"

  if (( ${choices[(Ie)$answer]} == 0 )); then
    fail "invalid AI CLI choice: $answer"
  fi

  export DOTFILES_AI_CLI="$answer"
}

prompt_jdtls_java() {
  stack_enabled java || return 0

  local answer
  read -r "answer?JDTLS Java version [$JDTLS_JAVA_VERSION] "
  answer="${answer:-$JDTLS_JAVA_VERSION}"
  export JDTLS_JAVA_VERSION="$answer"
}

write_install_env() {
  /bin/mkdir -p "$dotfiles_dir"
  {
    print -r -- "export DOTFILES_OPTIONAL_TOOLS=\"${DOTFILES_OPTIONAL_TOOLS:-}\""
    print -r -- "export DOTFILES_AI_CLI=\"${DOTFILES_AI_CLI:-none}\""
  } >| "$install_env"
}

write_local_env() {
  stack_enabled java || return 0

  if [[ ! -r "$local_env" ]] || ! /usr/bin/grep -q '^export JDTLS_JAVA_VERSION=' "$local_env"; then
    print -r -- "export JDTLS_JAVA_VERSION=\"$JDTLS_JAVA_VERSION\"" >> "$local_env"
  fi
}

build_brewfile() {
  local temp_brewfile="$1"
  /bin/cp "$core_brewfile" "$temp_brewfile"

  local stack stack_brewfile
  for stack in "${DOTFILES_STACKS[@]}"; do
    stack_brewfile="${dotfiles_dir}/Brewfile.stack.${stack}"
    # Not every stack needs Homebrew packages; some are mason-only.
    [[ -r "$stack_brewfile" ]] || continue
    print -- "" >> "$temp_brewfile"
    print -- "# Stack: ${stack}" >> "$temp_brewfile"
    /bin/cat "$stack_brewfile" >> "$temp_brewfile"
  done

  if (( minimal )); then
    print -- "install: --minimal, skipping quality-of-life apps"
  else
    print -- "" >> "$temp_brewfile"
    print -- "# Quality-of-life apps" >> "$temp_brewfile"
    /bin/cat "$qol_brewfile" >> "$temp_brewfile"
  fi

  print -- "" >> "$temp_brewfile"
  print -- "# Optional selections" >> "$temp_brewfile"

  local option
  local -a selected_options
  selected_options=(${=DOTFILES_OPTIONAL_TOOLS:-})
  for option in "${selected_options[@]}"; do
    /usr/bin/awk -v option="option:${option}" 'index($0, option) { print $0 }' "$optional_brewfile" >> "$temp_brewfile"
  done
}

install_brew_packages() {
  local temp_brewfile
  temp_brewfile="$(/usr/bin/mktemp)"
  build_brewfile "$temp_brewfile"
  /opt/homebrew/bin/brew bundle --file="$temp_brewfile"
  /bin/rm -f "$temp_brewfile"
}

ensure_nvm() {
  stack_enabled node || return 0

  export NVM_DIR="${NVM_DIR:-$HOME/.nvm}"

  # The Homebrew nvm formula installs to /opt/homebrew/opt/nvm and never
  # creates $NVM_DIR, so .config/zsh/tools.zsh would silently never load it.
  # Install from source instead, matching where tools.zsh looks.
  if [[ -s "$NVM_DIR/nvm.sh" ]]; then
    return
  fi

  /bin/mkdir -p "$NVM_DIR"
  /usr/bin/curl -fsSL \
    "https://raw.githubusercontent.com/nvm-sh/nvm/${NVM_VERSION}/install.sh" | /bin/bash
}

ensure_src_dir() {
  /bin/mkdir -p "$HOME/src"
}

ensure_sdkman() {
  stack_enabled java || return 0

  export SDKMAN_DIR="${SDKMAN_DIR:-$HOME/.sdkman}"

  if [[ ! -s "$SDKMAN_DIR/bin/sdkman-init.sh" ]]; then
    /usr/bin/curl -s "https://get.sdkman.io" | /bin/bash
  fi

  source "$SDKMAN_DIR/bin/sdkman-init.sh"

  if [[ -d "$SDKMAN_DIR/candidates/java/$JDTLS_JAVA_VERSION" ]]; then
    sdk use java "$JDTLS_JAVA_VERSION"
  else
    sdk install java "$JDTLS_JAVA_VERSION"
  fi
}

generate_tmuxinator_dev() {
  local template="${dotfiles_dir}/templates/tmuxinator/dev.yml.template"
  local output="${HOME}/.config/tmuxinator/dev.yml"
  local ai_command="${DOTFILES_AI_CLI:-none}"

  [[ "$ai_command" == "none" ]] && ai_command=""

  /bin/mkdir -p "$HOME/.config/tmuxinator"
  /usr/bin/sed "s/{{AI_CLI_COMMAND}}/${ai_command}/g" "$template" >| "$output"
}

ensure_git_email() {
  local email_file="${HOME}/.config/git/email.gitconfig"
  [[ -r "$email_file" ]] && return

  local email
  read -r "email?Git email for this machine: "
  [[ -n "$email" ]] || fail "Git email is required"

  /bin/mkdir -p "$HOME/.config/git"
  {
    print -- "[user]"
    print -- "  email = ${email}"
  } >| "$email_file"
}

bootstrap_tpm() {
  local tpm_dir="${HOME}/.tmux/plugins/tpm"
  if [[ ! -d "$tpm_dir" ]]; then
    /bin/mkdir -p "${HOME}/.tmux/plugins"
    /usr/bin/git clone https://github.com/tmux-plugins/tpm "$tpm_dir"
  fi

  "$tpm_dir/bin/install_plugins" >/dev/null 2>&1 || true
}

version_ge() {
  local current="${1#v}"
  local required="${2#v}"
  local -a current_parts required_parts
  current_parts=(${(s:.:)current})
  required_parts=(${(s:.:)required})

  local i current_part required_part
  for i in 1 2 3; do
    current_part="${current_parts[$i]:-0}"
    required_part="${required_parts[$i]:-0}"
    (( current_part > required_part )) && return 0
    (( current_part < required_part )) && return 1
  done

  return 0
}

validate_neovim() {
  local current
  current="$(nvim --version | /usr/bin/head -n 1 | /usr/bin/sed -E 's/^NVIM v([0-9.]+).*/\1/')"
  version_ge "$current" "$NEOVIM_MIN_VERSION" || fail "Neovim $NEOVIM_MIN_VERSION or newer is required; found $current"
}

main() {
  parse_args "$@"
  ensure_platform
  load_saved_choices
  prompt_stacks
  prompt_optional_tools
  prompt_ai_cli
  prompt_jdtls_java
  write_install_env
  write_local_env
  install_brew_packages
  ensure_nvm
  ensure_sdkman
  ensure_src_dir
  generate_tmuxinator_dev
  ensure_git_email
  bootstrap_tpm
  validate_neovim
  "${dotfiles_dir}/doctor.sh"
}

main "$@"
