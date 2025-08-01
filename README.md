# README

## Table of Contents

1. [Introduction](#introduction)
2. [Vim](#vim)
3. [Neovim](#neovim)
4. [Tmux](#tmux)
5. [Ripgrep](#ripgrep)
6. [Fonts](#fonts)
7. [Shells](#shells)
8. [Snippets](#snippets)

## Introduction

This repository includes two main scripts for setup:
- `install.sh`: Installs all required packages and tools
- `stow.sh`: Manages dotfile symlinks

### Package Installation

Run `install.sh` to install required packages (Homebrew, Neovim, Ripgrep, etc.):
```bash
./install.sh
```

### Stow

The `stow.sh` script manages all dotfile symlinks. Available commands:

```bash
# List available packages
./stow.sh list

# Preview what would happen during install (dry-run)
./stow.sh install --dry-run

# Install all dotfiles
./stow.sh install

# Remove all symlinks
./stow.sh remove

# Preview removal
./stow.sh remove --dry-run
```

### Manual Stow Usage (if needed)

For manual stow operations, you can use these commands:
- `stow <packagename>`: activates symlink
- `stow -n <packagename>`: trial runs or simulates symlink generation
- `stow -D <packagename>`: delete stowed package
- `stow -R <packagename>`: restows package
- `stow --adopt <packagename>`: adopts existing files into the stow directory

## Vim

- [amix/vimrc](https://github.com/amix/vimrc)

## Neovim

- This configuration is based on [kickstart.nvim](https://github.com/nvim-lua/kickstart.nvim)
- Uses [lazy.nvim](https://github.com/folke/lazy.nvim) as the plugin manager
- Includes LSP support via Mason for automatic language server installation
- Custom plugins include:
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
- Ripgrep (for Telescope live grep)

### Language Server Support

Configured LSP servers:
- `lua_ls` (Lua)
- `clangd` (C++)
- `pyright` (Python)
- `gopls` (Go)
- `rust_analyzer` (Rust)

Additional tools installed via Mason:
- `stylua` (Lua formatter)
- `shfmt` (Shell script formatter)

## Tmux

This configuration uses `Ctrl-Space` as the prefix key instead of the default `Ctrl-b`.

### Essential Commands

**Session Management:**
- `tmux new -s <n>` - Create new session with name
- `tmux ls` - List sessions
- `tmux attach -t <n>` - Attach to session
- `tmux kill-session -t <n>` - Kill session

**Window Management:**
- `Prefix + c` - Create new window
- `Prefix + ,` - Rename current window
- `Prefix + n` - Next window
- `Prefix + p` - Previous window
- `Prefix + 0-9` - Switch to window by number

**Pane Management:**
- `Prefix + |` - Split vertically
- `Prefix + -` - Split horizontally
- `Alt + Arrow Keys` - Navigate panes (no prefix needed)
- `Prefix + x` - Close current pane
- `Prefix + z` - Toggle pane zoom

**Utility:**
- `Prefix + r` - Reload tmux config
- `Prefix + M` - Toggle mouse mode
- `Prefix + [` - Enter copy mode (use vim keys to navigate)
- `Prefix + d` - Detach from session

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
- [Starship](https://starship.rs/) prompt
- [Rye](https://rye-up.com/) Python environment management
- Common aliases for development

### FZF Configuration

The setup includes fzf for fuzzy finding. If you see "bat: command not found" errors, either:
1. Install `bat` for syntax highlighting: `brew install bat` (macOS) or `sudo apt install bat` (Linux)
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
```
