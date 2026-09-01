# Dotfiles

Personal macOS Apple Silicon development setup managed with a bare Git repository.

The repo tracks the portable parts of my shell, Git, tmux, tmuxinator, and Neovim setup. Machine-specific values such as Git email, local shell overrides, selected optional apps, credentials, and generated tmuxinator profiles are intentionally ignored.

## Requirements

- macOS on Apple Silicon
- Internet access for Homebrew, GitHub, SDKMAN, and plugin downloads
- A public or otherwise cloneable copy of this repo at `https://github.com/pritch90/dot-config.git`

### Corporate networks

On a network behind a TLS-inspecting proxy, outbound HTTPS is re-signed by an internal certificate authority. `curl` and Homebrew will reject those connections until they trust that CA, so **bootstrap fails at its first download** if the CA is missing.

Provision the trust store **manually before running bootstrap**:

1. Obtain the internal root CA certificate from your IT department.
2. Create `~/.ca_certs/` and place the certificate there.
3. Add a combined bundle at `~/.ca_certs/cert.pem` containing the system roots plus that certificate. `curl` and most language runtimes read this single file.

Then point the shell at it in `~/.config/zsh/work.zsh`, which is gitignored and sourced automatically when present:

```sh
export CERT_DIR="$HOME/.ca_certs"
export CERT_PATH="$CERT_DIR/cert.pem"
export SSL_CERT_FILE="$CERT_PATH"
export SSL_CERT_DIR="$CERT_DIR/"
export REQUESTS_CA_BUNDLE="$CERT_PATH"
export AWS_CA_BUNDLE="$CERT_PATH"
export NODE_EXTRA_CA_CERTS="$CERT_DIR/<root-ca>.crt"
```

The JDK keeps its own trust store, so import the CA separately with `keytool` if Java builds fail on TLS.

None of this is tracked. On a home network it is not needed at all.

## Fresh Install

Run the bootstrap script from a fresh machine:

```sh
/bin/zsh -c "$(curl -fsSL https://raw.githubusercontent.com/pritch90/dot-config/main/.config/dotfiles/bootstrap.sh)"
```

The bootstrap script:

- verifies macOS Apple Silicon
- installs Homebrew if missing
- clones this repo as a bare repo at `~/.cfg`
- backs up conflicting files under `~/.dotfiles-backup/`
- checks out tracked files into `$HOME`
- runs `~/.config/dotfiles/install.sh`

`install.sh` then asks for stacks, optional tools and a Git email, installs everything, prompts for `gh auth login` if needed, and offers to apply the macOS defaults.

### What bootstrap does not do

Worth knowing before you assume a new machine is finished:

- **GUI application preferences are not tracked.** iTerm2, Rectangle, VS Code, IntelliJ, Postman and Chrome all keep settings under `~/Library`, which is gitignored. Those apps get installed, but at factory settings.
- **Bootstrap sets `origin` to the HTTPS URL.** If you prefer an SSH remote, point it at your own host alias afterwards.

## Managed Files

Core tracked areas:

- `~/.zshrc`
- `~/.zprofile`
- `~/.gitconfig`
- `~/.tmux.conf`
- `~/.config/zsh/`
- `~/.config/nvim/`
- `~/.config/tmux/`
- `~/.config/tmuxinator/default.yml`
- `~/.config/dotfiles/`

Fonts are installed by Homebrew rather than tracked: `font-fira-code-nerd-font` is in the core tier because Neovim's icons depend on it.

Generated or local files are ignored:

- `~/.config/git/email.gitconfig`
- `~/.config/dotfiles/install.local.env`
- `~/.config/dotfiles/local.env`
- `~/.config/zsh/local.zsh`
- `~/.config/zsh/work.zsh`
- `~/.config/zsh/secrets.zsh`
- `~/.config/dotfiles/stacks`
- `~/.config/tmuxinator/dev.yml`
- `~/.config/nvim/.nvimlog`
- `~/Library/`

## Bare Repo Usage

The shell defines a `config` alias:

```sh
config status
config add ~/.zshrc
config commit -m "Update shell config"
config push
```

Equivalent full form:

```sh
git --git-dir="$HOME/.cfg" --work-tree="$HOME" status
```

## Stacks

A machine only needs the languages it actually works in. `~/.config/dotfiles/stacks` records which ones this machine is set up for — one per line, machine-local and gitignored:

```text
java
node
web
```

Known stacks: `java`, `node`, `web`, `go`, `python`, `terraform`.

That single file is the source of truth for three consumers:

| Consumer | Effect |
|---|---|
| `install.sh` | picks up `Brewfile.stack.<name>`; skips SDKMAN without `java`, skips nvm without `node` |
| `zsh` | gates `~/go/bin`, `PNPM_HOME`, the nvm eager-load and SDKMAN init |
| Neovim | installs and enables only that stack's LSPs, parsers, formatters and debug adapters |

Set it during install, or non-interactively:

```sh
~/.config/dotfiles/install.sh --stacks java,node,web
```

Edit the file by hand to change later — restart your shell and Neovim and it takes effect. No reinstall needed unless you want the Homebrew packages too.

Two behaviours worth knowing:

- **`web` implies `node`.** Its language servers are node processes, so selecting `web` enables `node` automatically.
- **Disabling never uninstalls.** Turning a stack off deactivates it in the shell and Neovim, but leaves the Homebrew packages alone. Remove them yourself if you want the disk space back.
- **A missing `stacks` file means everything is on.** That keeps a machine that has not run the installer working exactly as before.

### Adding a stack

1. Create `~/.config/nvim/lua/stacks/<name>.lua` returning any of `mason`, `treesitter`, `lsp`, `formatters`, and a `setup(ctx)` function for anything that is not a plain list.
2. Add the name to `known` in `~/.config/nvim/lua/stacks/init.lua` and to `DOTFILES_KNOWN_STACKS` in `~/.config/zsh/stacks.zsh`.
3. Add `~/.config/dotfiles/Brewfile.stack.<name>` if it needs Homebrew packages. Stacks whose tooling comes entirely from mason do not need one.

## Installation

Packages are split across tiers:

```text
~/.config/dotfiles/Brewfile.core          always installed
~/.config/dotfiles/Brewfile.stack.<name>  per selected stack
~/.config/dotfiles/Brewfile.qol           installed by default, skip with --minimal
~/.config/dotfiles/Brewfile.optional      prompted for, one question per tool
```

`Brewfile.core` is stack-agnostic: Git, shell, editor, search and container tooling.

`Brewfile.qol` is the quality-of-life app layer — browser, terminal, window manager, API client, music and peripherals. It is installed by default. Skip it for a lean or throwaway machine:

```sh
~/.config/dotfiles/install.sh --minimal
```

`install.sh` asks which stacks and optional tools to install before running Homebrew, then installs everything in one batch. It stores local choices in:

```text
~/.config/dotfiles/install.local.env
```

Current optional tool keys:

- `codex_app`
- `codex_tui`
- `claude_desktop`
- `claude_code`
- `copilot_app`
- `copilot_cli`
- `intellij`
- `awscli`
- `aws_vault`
- `mongosh`
- `vscode`

## Neovim

Neovim is installed with Homebrew. The config expects Neovim `0.12.0` or newer because it uses `vim.pack` and current LSP APIs.

Language tooling follows the selected stacks — see [Stacks](#stacks). `~/.config/nvim/lua/stacks/` holds one module per stack, and `init.lua` merges whichever are enabled into the mason, treesitter, LSP and formatter lists.

JDTLS Java is pinned through:

```text
~/.config/dotfiles/versions.env
```

Override the pin locally in:

```text
~/.config/dotfiles/local.env
```

Example:

```sh
export JDTLS_JAVA_VERSION="25.0.3-amzn"
```

## Node

Requires the `node` stack; without it none of this is installed or loaded.

`nvm` is **not** installed with Homebrew. The formula installs to `/opt/homebrew/opt/nvm` and never creates `$NVM_DIR` (`~/.nvm`), which is where `~/.config/zsh/tools.zsh` looks for it — so a brewed nvm silently never loads on a fresh machine.

`install.sh` installs it from source with `curl` instead, into `~/.nvm`. The step is idempotent and skipped if `$NVM_DIR/nvm.sh` already exists. The version is pinned in:

```text
~/.config/dotfiles/versions.env
```

`node`, `pnpm` and `yarn` are still installed via Homebrew for a working default toolchain; use `nvm` when a project needs a specific Node version.

## tmuxinator

`default.yml` is tracked directly.

`dev.yml` is generated from:

```text
~/.config/dotfiles/templates/tmuxinator/dev.yml.template
```

The installer asks which AI CLI should be used in the AI pane. The selected command is local to the machine.

## Backups And Restore

Bootstrap and manual restore operations write backups to:

```text
~/.dotfiles-backup/
```

Restore the latest snapshot:

```sh
~/.config/dotfiles/restore.sh
```

Restore a named snapshot:

```sh
~/.config/dotfiles/restore.sh bootstrap-20260706-143000
```

The restore script prints the files it will restore and creates a fresh pre-restore backup first.

## Public Safety Check

Run:

```sh
~/.config/dotfiles/doctor.sh
```

The doctor script scans tracked files for obvious private/work-only values such as tokens, company domains, and certificate references. It also scans tracked *paths*, since a directory name can leak an employer even when no file content does.

It exits non-zero on a match, so it works as a pre-push check and runs from any directory.

## macOS Defaults

System settings that differ from Apple's defaults live in:

```text
~/.config/dotfiles/macos.sh
```

It covers the Dock (left-hand, hidden, smaller tiles), Finder (column view, status bar) and trackpad (tap to click). Everything else is deliberately left at the system default rather than guessed at.

`install.sh` offers to run it. It is idempotent, so apply it any time:

```sh
zsh ~/.config/dotfiles/macos.sh
```

It restarts Dock and Finder to make changes take effect. A few settings still need a logout.

## Git Identity

The tracked Git config includes my name only. Email is local:

```text
~/.config/git/email.gitconfig
```

Example:

```ini
[user]
  email = you@example.com
```

Credentials for `github.com` are delegated to the GitHub CLI, so a machine needs `gh auth login` before it can push. `install.sh` prompts for this.

## AWS Vault

Install `aws-vault` by selecting the `aws_vault` optional tool during `install.sh`. Install `awscli` as well if the machine does not already have the AWS CLI.

Add long-lived credentials for a profile:

```sh
aws-vault add personal
```

Then create or edit `~/.aws/config`:

```ini
[profile personal]
region = eu-west-1
output = json
```

Run a command with that profile:

```sh
aws-vault exec personal -- aws sts get-caller-identity
```

Open a shell with temporary credentials:

```sh
aws-vault exec personal -- zsh
```

For role-based profiles, keep source credentials in one profile and define the role profile in `~/.aws/config`:

```ini
[profile personal]
region = eu-west-1
output = json

[profile personal-admin]
source_profile = personal
role_arn = arn:aws:iam::123456789012:role/Admin
region = eu-west-1
output = json
```

Then run:

```sh
aws-vault exec personal-admin -- aws sts get-caller-identity
```

For AWS IAM Identity Center/SSO profiles, configure the profile with the AWS CLI:

```sh
aws configure sso --profile personal-sso
aws sso login --profile personal-sso
aws-vault exec personal-sso -- aws sts get-caller-identity
```

Useful commands:

```sh
aws-vault list
aws-vault remove personal
aws-vault clear
```

Do not commit `~/.aws/credentials`, `~/.aws/config`, or any exported AWS tokens to this repo.

## Maintenance

Run the installer again after editing Brewfiles or changing optional tool selections:

```sh
~/.config/dotfiles/install.sh
```

Check staged public safety before pushing:

```sh
~/.config/dotfiles/doctor.sh
config status
```
