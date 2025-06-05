# README

## Table of Contents

1. [Introduction](#introduction)
2. [Vim](#vim)
3. [Neovim](#neovim)
4. [Ripgrep](#ripgrep)
5. [Fonts](#fonts)
6. [Shells](#shells)
7. [Snippets](#snippets)

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