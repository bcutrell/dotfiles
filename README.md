# README

## Table of Contents

1. [Introduction](#introduction) - quick start, tiers, cleanup
2. [Vim](#vim)
3. [Neovim](#neovim)
4. [Tmux](#tmux)
5. [Clipboard](#clipboard)
6. [Fonts](#fonts)
7. [Shells](#shells)
8. [Snippets](#snippets)

## Introduction

This repository includes two main scripts:
- `setup.sh`: installs packages and links dotfiles
- `clean.sh`: removes symlinks, clears caches, uninstalls Homebrew

### Quick Start

```bash
git clone https://github.com/bcutrell/dotfiles.git ~/dotfiles
cd ~/dotfiles
sh setup.sh
```

Same on macOS and Debian/Ubuntu. `setup.sh` is POSIX `sh` and needs no
dependencies of its own, not even GNU Stow.

### Starting Fresh

To replace an existing setup, including the older stow-based one:

```bash
# 1. remove the old symlinks and restore whatever they replaced
cd ~/dotfiles && sh clean.sh unlink

# 2. delete the old checkout
cd ~ && rm -rf ~/dotfiles

# 3. clone and set up
git clone https://github.com/bcutrell/dotfiles.git ~/dotfiles
cd ~/dotfiles && sh setup.sh
```

Skip step 1 if the old checkout is already gone: `setup.sh` backs up anything
it finds at a target path anyway.

### Setup Options

```bash
sh setup.sh              # asks which tier
sh setup.sh --minimal    # weak box: git, curl, tmux, plugin-free vim
sh setup.sh --full       # workstation: adds Neovim + LSP, Node, fzf, ripgrep, starship
sh setup.sh --link-only  # symlinks only, install nothing
sh setup.sh --yes        # no prompts, take every default
sh setup.sh --check      # report OS, tools and link status; changes nothing
```

Re-running is safe. Switching tiers is just re-running with the other flag;
`~/.vimrc` swaps between the plugin-free and full configs automatically.

### What Gets Linked

`setup.sh` links only what `manifest()` in `lib.sh` names. Anything already at a
target path moves to `~/.dotfiles_backup/<timestamp>/` first.

| Repo | Links to | Tier |
|------|----------|------|
| `shell/.zshrc`, `.bashrc`, `.aliases` | `~/` | both |
| `git/.gitconfig`, `.gitignore_global` | `~/` | both |
| `tmux/.tmux.conf` | `~/.tmux.conf` | both |
| `vim-light/.vimrc` | `~/.vimrc` | minimal |
| `vim/.vimrc` | `~/.vimrc` | full |
| `nvim/.config/nvim` | `~/.config/nvim` | full |
| `config/.config/starship.toml` | `~/.config/starship.toml` | full |

Git identity and the credential helper go in `~/.gitconfig.local`, which
`.gitconfig` includes and git ignores. That keeps the tracked `.gitconfig`
portable across macOS and Linux.

### Cleanup

```bash
sh clean.sh doctor    # what is installed and linked
sh clean.sh cache     # remove build/tool caches (asks per item)
sh clean.sh brew      # uninstall Linuxbrew/Homebrew, strip brew shellenv
sh clean.sh unlink    # remove symlinks, restore newest backup
sh clean.sh all       # cache, then unlink
```

`cache` covers what actually fills a small VM: pip, npm, Homebrew, Go, Neovim
plugins and LSP servers, apt, the shell init caches, and old backups. It always
keeps the newest backup.

### Testing

Linux paths are tested in containers. Requires Docker:

```bash
./docker-test.sh build      # build debian + ubuntu images
./docker-test.sh test       # syntax, minimal install, clean shells, unlink
./docker-test.sh test-full  # full install
./docker-test.sh test-nvim  # headless Neovim config load
./docker-test.sh cleanup    # remove images
```

See `TEST_PLAN.md`.

## Vim

- [amix/vimrc](https://github.com/amix/vimrc)

## Neovim

- This configuration is based on [kickstart.nvim](https://github.com/nvim-lua/kickstart.nvim)
- Uses [lazy.nvim](https://github.com/folke/lazy.nvim) as the plugin manager
- Includes LSP support via Mason for automatic language server installation
- Custom plugins include:
  - [fzf-lua](https://github.com/ibhagwan/fzf-lua) for finding files and grepping
  - [Harpoon](https://github.com/ThePrimeagen/harpoon) for file navigation
  - [Oil.nvim](https://github.com/stevearc/oil.nvim) for file management
  - [VimWiki](https://github.com/vimwiki/vimwiki) for note-taking

### Neovim Requirements

The configuration requires:
- Neovim 0.9.0+ (for lazy.nvim compatibility)
- Git (for plugin management)
- A C compiler (for some plugin builds)
- Node.js (for some LSP servers)
- Python 3 (for some LSP servers)
- Ripgrep (for fzf-lua live grep)

### Language Server Support

Configured LSP servers:
- `lua_ls` (Lua)
- `clangd` (C++)
- `pyright` (Python)
- `gopls` (Go)
- `rust_analyzer` (Rust)
- `ts_ls` (JavaScript/TypeScript)

Additional tools installed via Mason:
- `stylua` (Lua formatter)
- `prettier` (JS/TS/JSON/Markdown formatter)

Formatting runs through [conform.nvim](https://github.com/stevearc/conform.nvim),
which also uses `shfmt` for shell if installed.

## Tmux

This configuration uses the default `Ctrl-b` prefix key.

### Essential Commands

**Session Management:**
- `tmux new -s <n>` - Create new session with name
- `tmux ls` - List sessions
- `tmux attach -t <n>` - Attach to session
- `tmux kill-session -t <n>` - Kill session

**Window Management:**
- `Prefix + c` - Create new window (in the current pane's directory)
- `Prefix + ,` - Rename current window
- `Prefix + n` - Next window
- `Prefix + p` - Previous window
- `Prefix + 1-9` - Switch to window by number (windows start at 1)

**Pane Management:**
- `Prefix + |` - Split left/right (same directory)
- `Prefix + -` - Split top/bottom (same directory)
- `Prefix + Arrow Keys` - Navigate panes
- `Prefix + H/J/K/L` - Resize by 5, repeatable (hold the key)
- `Prefix + x` - Close current pane
- `Prefix + z` - Toggle pane zoom

**Utility:**
- `Prefix + r` - Reload tmux config
- `Prefix + m` - Toggle mouse mode (off by default)
- `Prefix + [` - Enter copy mode (vi keys: `v` select, `y` copy, `q` exit)
- `Prefix + d` - Detach from session

See `tmux/TMUX_GUIDE.md` for the full reference.

## Clipboard

Copying on a remote machine puts the text on your local clipboard, so a yank
over SSH pastes into any Mac app. This uses OSC 52: the copy is encoded into a
terminal escape sequence that travels back through SSH and tmux. Nothing to
install remotely, no X11 forwarding.

- `tmux`: `set-clipboard on` forwards OSC 52 from programs inside it, and emits
  it for its own copy-mode yanks. The default, `external`, only forwards.
- `nvim`: OSC 52 provider when `$SSH_TTY` is set, system clipboard locally
- `vim`, `vim-light`: emitted from a `TextYankPost` autocmd

Your terminal must allow it. In iTerm2: Settings > General > Selection >
"Applications in terminal may access clipboard". Terminal.app has no OSC 52
support.

Pasting the other way, Mac to remote, is your terminal's own paste (`Cmd+V`) and
needs no configuration. Most terminals refuse OSC 52 *reads*, so nothing here
attempts one. Very large yanks are skipped.

## Fonts

- [JetBrains Mono](https://www.jetbrains.com/lp/mono/): optional, provides various icons
- [Nerd Font](https://www.nerdfonts.com/): More options and better icon support for Neovim

**Note**: Set `vim.g.have_nerd_font = true` in your Neovim config if you have a Nerd Font installed.

## Shells

In order of preference:

1. [ohmyz.sh](https://ohmyz.sh/#install)
2. bash-it: `git clone --depth=1 https://github.com/Bash-it/bash-it.git ~/.bash_it && ~/.bash_it/install.sh`
3. fish: `brew install fish`

Both `.zshrc` and `.bashrc` are configured with:
- [Starship](https://starship.rs/) prompt when installed, otherwise a native
  prompt with the git branch
- [Rye](https://rye-up.com/) Python environment management, if present
- Common aliases for development, shared via `shell/.aliases`

Every optional tool is guarded, so a shell on a bare box prints nothing on
startup. Generated `starship` and `fzf` init is cached under `~/.cache/zsh` and
`~/.cache/bash`; sourcing that is faster than re-running each tool per shell.

### FZF Configuration

The full tier includes fzf: `Ctrl+R` history, `Ctrl+T` files, `Alt+C` cd.
Debian and Ubuntu ship `bat` as `batcat`; the shells alias around that. If you
still see "bat: command not found", either:
1. Install `bat`: `brew install bat` (macOS) or `sudo apt install bat` (Linux)
2. Or configure fzf to use `cat` instead by adding to your shell config:
   ```bash
   export FZF_DEFAULT_OPTS='--preview "cat {}"'
   ```

### Passwordless SSH

Generate an SSH key pair on your local machine:
```bash
ssh-keygen -t rsa -b 4096
```

Accept the default location (`~/.ssh/id_rsa`) or specify a custom path. Copy the public key to your remote server:
```bash
ssh-copy-id user@remote-server
# or manually: cat ~/.ssh/id_rsa.pub | ssh user@remote-server "mkdir -p ~/.ssh && cat >> ~/.ssh/authorized_keys"
```

For custom key locations, use:
```bash
ssh -i /path/to/custom/key user@remote-server
```

Or create an SSH config file (`~/.ssh/config`):
```
Host myserver
    HostName remote-server.com
    User username
    IdentityFile ~/.ssh/custom_key
```

## Snippets

```shell
# Change shell
# per session
$ exec zsh -l  # switch to zsh
$ exec bash -l # switch to bash

# per login
$ chsh -s $(which bash)
$ chsh -s $(which zsh)

# list shells
$ cat /etc/shells

# install java
$ brew install java
$ sudo ln -sfn /opt/homebrew/opt/openjdk/libexec/openjdk.jdk /Library/Java/JavaVirtualMachines/openjdk.jdk

# enable key repeat for mac IDEs
$ defaults write "$(osascript -e 'id of app "<IDE>"')" ApplePressAndHoldEnabled -bool false
$ defaults write com.microsoft.VSCode ApplePressAndHoldEnabled -bool false

# neovim package management
$ nvim +Lazy                    # open lazy.nvim interface
$ nvim +Mason                   # open mason interface for LSPs
$ nvim +checkhealth             # check neovim health

# fix clipboard on debian
$ sudo apt install xclip
```
