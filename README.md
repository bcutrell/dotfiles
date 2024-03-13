## Stow

### Mac

```
brew install stow
```

### Debian

```
sudo apt stow
```

### Usage

```
stow <packagename> # activates symlink
stow -n <packagename> # trial runs or simulates symlink generation. Effective for checking for errors
stow -D <packagename> # delete stowed package
stow -R <packagename> # restows package
stow bash git nvim # install packages
```
## Vim

https://github.com/amix/vimrc

## Neovim

https://github.com/nvim-lua/kickstart.nvim

### Mac

```
brew install nvim
```

### Debian

```
sudo apt-get install neovim

or

nvim --version | head -n 1
wget https://github.com/neovim/neovim/releases/download/v0.9.1/nvim.appimage
chmod u+x nvim.appimage && ./nvim.appimage
./nvim.appimage --appimage-extract
./squashfs-root/usr/bin/nvim

optional
ln -s /usr/bin/nvim /usr/bin/vim
cp ./squashfs-root/usr/bin/nvim usr/bin/nvim
```

## Ripgrep

- [ripgrep](https://github.com/BurntSushi/ripgrep#installation)

### Mac

```
brew install ripgrep
```

### Debain

```
$ sudo apt-get install ripgrep
```

## Fonts

- A [Nerd Font](https://www.nerdfonts.com/): optional, provides various icons

## Poetry

- tab completion
```
mkdir $ZSH_CUSTOM/plugins/poetry
poetry completions zsh > $ZSH_CUSTOM/plugins/poetry/_poetry
```

## oh my zsh

https://ohmyz.sh/#install
