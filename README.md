# Dotfiles

Personal macOS Apple Silicon development setup managed with a bare Git repository.

The repo tracks the portable parts of my shell, Git, tmux, tmuxinator, and Neovim setup. Machine-specific values such as Git email, local shell overrides, selected optional apps, credentials, and generated tmuxinator profiles are intentionally ignored.

## Requirements

- macOS on Apple Silicon
- Internet access for Homebrew, GitHub, SDKMAN, and plugin downloads
- A public or otherwise cloneable copy of this repo at `https://github.com/pritch90/dot-config.git`

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

Generated or local files are ignored:

- `~/.config/git/email.gitconfig`
- `~/.config/dotfiles/install.local.env`
- `~/.config/dotfiles/local.env`
- `~/.config/zsh/local.zsh`
- `~/.config/zsh/work.zsh`
- `~/.config/zsh/secrets.zsh`
- `~/.config/tmuxinator/dev.yml`

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

## Installation

Core packages are listed in:

```text
~/.config/dotfiles/Brewfile.core
```

Optional packages are listed in:

```text
~/.config/dotfiles/Brewfile.optional
```

`install.sh` asks which optional tools to install before running Homebrew, then installs everything in one batch. It stores local choices in:

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

The doctor script scans tracked files for obvious private/work-only values such as tokens, company domains, and certificate references.

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
