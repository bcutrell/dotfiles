# README

## Table of Contents

1. [Stow](#stow)
2. [Vim](#vim)
3. [Neovim](#neovim)
4. [Ripgrep](#ripgrep)
5. [Fonts](#fonts)
6. [Shells](#shells)
7. [Snippets](#snippets)
8. [Neovim HotKeys](#neovim-hotkeys)

## Stow

### Installation

- Mac: `brew install stow`
- Debian: `sudo apt-get install stow`

### Usage

- `stow <packagename>`: activates symlink
- `stow -n <packagename>`: trial runs or simulates symlink generation. Effective for checking for errors
- `stow -D <packagename>`: delete stowed package
- `stow -R <packagename>`: restows package
- `stow bash git nvim`: install packages

## Vim

- [amix/vimrc](https://github.com/amix/vimrc)

## Neovim

- [nvim-lua/kickstart.nvim](https://github.com/nvim-lua/kickstart.nvim)

### Installation

- Mac: `brew install nvim`
- Debian: [Installation Instructions](#debian-neovim-installation)

#### Debian Neovim Installation

```shell
sudo apt-get install neovim

# or

nvim --version | head -n 1
wget https://github.com/neovim/neovim/releases/download/v0.9.1/nvim.appimage
chmod u+x nvim.appimage && ./nvim.appimage
./nvim.appimage --appimage-extract
./squashfs-root/usr/bin/nvim

# optional
ln -s /usr/bin/nvim /usr/bin/vim
cp ./squashfs-root/usr/bin/nvim usr/bin/nvim
```

## Ripgrep

- [Installation Instructions](https://github.com/BurntSushi/ripgrep#installation)

## Fonts

- [Nerd Font](https://www.nerdfonts.com/): optional, provides various icons

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
```

## Neovim HotKeys

- `<leader>ds` : Document Symbols
- `<leader>ss` : Search Symbols
- `K` : Documentation
- `gs` : (Functionality not specified)
- `gd` : (Functionality not specified)