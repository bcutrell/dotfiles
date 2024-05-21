#!/usr/bin/env zsh

#
# Xcode CLI tools
#
if [[ "$OSTYPE" == "darwin"* ]]; then
    echo "Installing Xcode CLI tools..."
    xcode-select --install
fi

#
# Oh My Zsh
#
# https://ohmyz.sh/#install
echo "Oh My Zsh is a delightful, open source, community-driven framework for managing your Zsh configuration. Would you like to install it?"
read -q "Install Oh My Zsh? (y/n) " choice

if [[ $choice = "y" || $choice = "Y" ]]; then
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
    echo "Oh My Zsh installed!"
else
    echo "Skipping Oh My Zsh installation."
fi

#
# Rye
#
# https://rye-up.com/
echo "rye is a python package manager. Would you like to install it?"
read -q "Install rye? (y/n) " choice

if [[ $choice = "y" || $choice = "Y" ]]; then
    curl -sSf https://rye-up.com/get | bash
    echo "rye installed!"
else
    echo "Skipping rye installation."
fi

#
# Neovim
#
echo "neovim is a hyperextensible text editor based on Vim. Would you like to install it without using Homebrew?"
read -q "Install neovim without Homebrew? (y/n) " choice

if [[ $choice = "y" || $choice = "Y" ]]; then
    if [[ "$OSTYPE" == "linux"* ]]; then
        echo "Detected Linux OS..."
        # Check if nvim is already installed
        if ! command -v nvim &> /dev/null; then
            echo "neovim could not be found, installing using wget..."
            wget https://github.com/neovim/neovim/releases/download/v0.9.1/nvim.appimage
            chmod u+x nvim.appimage && ./nvim.appimage
            ./nvim.appimage --appimage-extract
            sudo cp ./squashfs-root/usr/bin/nvim /usr/bin/nvim
        fi
    elif [[ "$OSTYPE" == "darwin"* ]]; then
        echo "Detected MacOS..."
        # Check if nvim is already installed
        if ! command -v nvim &> /dev/null; then
            curl -LO https://github.com/neovim/neovim/releases/download/nightly/nvim-macos-x86_64.tar.gz
            tar xzf nvim-macos-x86_64.tar.gz
            ./nvim-macos-x86_64/bin/nvim
        fi
    else
        echo "Unsupported OS detected. This script supports Linux and MacOS only."
        exit 1
    fi
fi

#
# Homebrew
#
# https://sourabhbajaj.com/mac-setup/
# https://docs.brew.sh/Homebrew-on-Linux
#
# Linux Homebrew Path
# test -d ~/.linuxbrew && eval "$(~/.linuxbrew/bin/brew shellenv)"
# test -d /home/linuxbrew/.linuxbrew && eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
# echo "eval \"\$($(brew --prefix)/bin/brew shellenv)\"" >> ~/.zshrc
#
# Mac Homebrew Path
# echo "eval \"\$(/opt/homebrew/bin/brew shellenv)\"" >> ~/.zshrc
echo "Homebrew is a package manager for macOS and Linux. Would you like to install it?"
read -q "Install Homebrew? (y/n) " choice
if [[ $choice = "y" || $choice = "Y" ]]; then
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
    else
        echo "Homebrew installed!"

        # Homebrew cleanup...
        brew update
        brew upgrade
        brew upgrade --cask
        brew cleanup
    fi
fi

# Check if Homebrew is installed, if not, exit
if ! command -v brew &>/dev/null; then
    echo "Homebrew is not installed. Skipping package and app installations."
    echo
    exit 1
fi

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
    "gum"
    "glow"
)

echo "Install the following packages with Homebrew?"
echo "${packages[@]}"
read -q "Install packages? (y/n) " choice

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

echo "Install the following apps? with Homebrew?"
echo "${apps[@]}"

read -q "Install apps? (y/n) " choice
if [[ $choice = "y" || $choice = "Y" ]]; then
    for app in "${apps[@]}"; do
        if brew list --cask | grep -q "^$app\$"; then
            echo "$app is already installed. Skipping..."
        else
            echo "Installing $app..."
            brew install --cask "$app"
        fi
    done
fi