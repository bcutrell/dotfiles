## Stow

sudo apt stow # Ubuntu
brew install stow # Homebrew Mac

stow <packagename> # activates symlink
stow -n <packagename> # trial runs or simulates symlink generation. Effective for checking for errors
stow -D <packagename> # delete stowed package
stow -R <packagename> # restows package
stow bash git nvim

## Neovim

https://github.com/nvim-lua/kickstart.nvim

brew install nvim # Homebrew Mac

# Debian

nvim --version | head -n 1
wget https://github.com/neovim/neovim/releases/download/v0.9.1/nvim.appimage
chmod u+x nvim.appimage && ./nvim.appimage
./nvim.appimage --appimage-extract
./squashfs-root/usr/bin/nvim

optional
ln -s /usr/bin/nvim /usr/bin/vim
cp ./squashfs-root/usr/bin/nvim usr/bin/nvim

# Ripgrep

- [ripgrep](https://github.com/BurntSushi/ripgrep#installation)

brew install ripgrep # Homebrew Mac
$ sudo apt-get install ripgrep # Debain

# Fonts

- A [Nerd Font](https://www.nerdfonts.com/): optional, provides various icons
