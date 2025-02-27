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

## Fonts

- [JetBrains Mono](https://www.jetbrains.com/lp/mono/): optional, provides various icons
- [Nerd Font](https://www.nerdfonts.com/): More options

## Shells

In order of preference:

1. [ohmyz.sh](https://ohmyz.sh/#install)
2. bash-it: `git clone --depth=1 https://github.com/Bash-it/bash-it.git ~/.bash_it && ~/.bash_it/install.sh`
3. fish: `brew install fish`

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
```
