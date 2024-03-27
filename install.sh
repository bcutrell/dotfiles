#!/usr/bin/env zsh

# Resources
# https://sourabhbajaj.com/mac-setup/
# https://github.com/pyenv/pyenv
# https://docs.anaconda.com/free/miniconda/index.html
# https://rye-up.com/
# https://docs.brew.sh/Homebrew-on-Linux

# Linux Homebrew Path
# test -d ~/.linuxbrew && eval "$(~/.linuxbrew/bin/brew shellenv)"
# test -d /home/linuxbrew/.linuxbrew && eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
# echo "eval \"\$($(brew --prefix)/bin/brew shellenv)\"" >> ~/.zshrc

# Mac Homebrew Path
# echo "eval \"\$(/opt/homebrew/bin/brew shellenv)\"" >> ~/.zshrc

# Mac CLI tools
if [[ "$OSTYPE" == "darwin"* ]]; then
    echo "Installing Xcode CLI tools..."
    xcode-select --install
fi

# Homebrew
if ! command -v brew &>/dev/null; then
    echo "Installing Homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
else
    echo "Homebrew is already installed."
fi

if ! command -v brew &>/dev/null; then
    echo "Failed to configure Homebrew in PATH. Please add Homebrew to your PATH manually."
    echo
    exit 1
fi

# Normal vim
echo "Pathogen is a popular Vim plugin manager. Would you like to install it?"
read -q "Install Pathogen? (y/n) " choice

if [[ $choice = "y" || $choice = "Y" ]]; then
    mkdir -p ~/.vim/autoload ~/.vim/bundle
    curl -LSso ~/.vim/autoload/pathogen.vim https://tpope.io/vim/pathogen.vim
    echo "Pathogen installed!"
else
    echo "Skipping Pathogen installation."
fi

# Homebrew cleanup...
brew update
brew upgrade
brew upgrade --cask
brew cleanup

#
# Install packages
#
packages=(
    "python3"
    "go"
    "rust"
    "node"
    "nvim"
    "bash"
    "zsh"
    "git"
    "tree"
    "fzf"
    "ack"
    "ripgrep"
    "gh" # github
)

for package in "${packages[@]}"; do
    if brew list --formula | grep -q "^$package\$"; then
        echo "$package is already installed. Skipping..."
    else
        echo "Installing $package..."
        brew install "$package"
    fi
done

#
# Install apps
#
apps=(
    "google-chrome"
    "firefox"
    "rectangle"
    "postman"
)

for app in "${apps[@]}"; do
    if brew list --cask | grep -q "^$app\$"; then
        echo "$app is already installed. Skipping..."
    else
        echo "Installing $app..."
        brew install --cask "$app"
    fi
done

# Homebrew cleanup...
brew update
brew upgrade
brew upgrade --cask
brew cleanup
