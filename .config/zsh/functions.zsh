kport() {
  if [[ -z "${1:-}" ]]; then
    print -u2 -- "Usage: kport <port>"
    return 1
  fi

  local pid
  pid="$(lsof -t -i :"$1")"
  if [[ -z "$pid" ]]; then
    print -u2 -- "No process found on port $1"
    return 1
  fi

  print -- "Killing PID $pid on port $1"
  kill -9 "$pid"
}

sdk_use_java() {
  local version="$1"
  if [[ -z "$version" ]]; then
    print -u2 -- "Usage: sdk_use_java <version>"
    return 1
  fi

  if ! command -v sdk >/dev/null 2>&1; then
    print -u2 -- "SDKMAN is not available"
    return 1
  fi

  sdk use java "$version" || {
    sdk install java "$version"
    sdk use java "$version"
  }
}

j8()  { sdk_use_java 8.0.442-amzn; }
j11() { sdk_use_java 11.0.26-amzn; }
j17() { sdk_use_java 17.0.15-amzn; }
j21() { sdk_use_java 21.0.6-amzn; }
j23() { sdk_use_java 23.0.2-amzn; }
j21o(){ sdk_use_java 21.0.6-oracle; }
j23o(){ sdk_use_java 23.0.2-oracle; }

tf() {
  if ! command -v fzf >/dev/null 2>&1; then
    print -u2 -- "tf requires fzf"
    return 1
  fi

  local session session_name
  session="$(tmux ls 2>/dev/null | fzf --prompt="tmux sessions> " --height=40%)" || return 1
  [[ -n "$session" ]] || return 1

  session_name="${session%%:*}"
  if [[ -z "$TMUX" ]]; then
    tmux attach-session -t "$session_name"
  else
    tmux switch-client -t "$session_name"
  fi
}

ts() {
  local profile=default
  local OPTIND opt
  while getopts ":d" opt; do
    case "$opt" in
      d) profile=dev ;;
      *) print -u2 -- "Usage: ts [-d] <session-name> [dir]"; return 1 ;;
    esac
  done
  shift $((OPTIND - 1))

  local name="$1"
  local dir="${2:-.}"
  if [[ -z "$name" ]]; then
    print -u2 -- "Usage: ts [-d] <session-name> [dir]"
    return 1
  fi

  local resolved
  if ! resolved="$(zsh -dfc 'cd -- "$1" 2>/dev/null && pwd -P' -- "$dir")"; then
    print -u2 -- "ts: dir not found: $dir"
    return 1
  fi

  TS_ROOT="$resolved" tmuxinator start "$profile" --name "$name"
}

set_project_versions() {
  local repo_root
  repo_root="$(git -C . rev-parse --show-toplevel 2>/dev/null)" || repo_root="$PWD"

  if [[ -e "$repo_root/.nvmrc" && "${last_node_version:-}" != "$(< "$repo_root/.nvmrc")" ]]; then
    export last_node_version="$(< "$repo_root/.nvmrc")"
    command -v nvm >/dev/null 2>&1 || load_nvm
    command -v nvm >/dev/null 2>&1 || return 0
    nvm use
  fi

  if [[ -e "$repo_root/.java-version" && "${last_java_dir:-}" != "$repo_root" ]]; then
    local java_version
    java_version="$(< "$repo_root/.java-version")"
    case "$java_version" in
      1.8) j8 ;;
      11*) j11 ;;
      17*) j17 ;;
      21*) j21 ;;
    esac
    export last_java_dir="$repo_root"
  fi
}

chpwd() {
  set_project_versions
}

set_project_versions
