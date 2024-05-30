#!/bin/sh

# Xcode CLI tools
if [ "$(uname)" = "Darwin" ]; then
    echo "Installing Xcode CLI tools..."
    xcode-select --install
fi

# Function to prompt user for installation
prompt_install() {
    while true; do
        echo "$1 (y/n)"
        read -r choice
        case "$choice" in
            y|Y ) return 0;;
            n|N ) return 1;;
            * ) echo "Please answer y or n.";;
        esac
    done
}

# Oh My Zsh
echo "Oh My Zsh is a delightful, open source, community-driven framework for managing your Zsh configuration. Would you like to install it?"
if prompt_install "Install Oh My Zsh?"; then
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
    echo "Oh My Zsh installed!"
else
    echo "Skipping Oh My Zsh installation."
fi

# Rye
echo "rye is a python package manager. Would you like to install it?"
if prompt_install "Install rye?"; then
    curl -sSf https://rye-up.com/get | sh
    echo "rye installed!"
else
    echo "Skipping rye installation."
fi



# Neovim
echo "neovim is a hyperextensible text editor based on Vim. Would you like to install it without using Homebrew?"
if prompt_install "Install neovim without Homebrew?"; then
    if [ "$(uname)" = "Linux" ]; then
        echo "Detected Linux OS..."
        if ! command -v nvim >/dev/null 2>&1; then
        curl -LO https://github.com/neovim/neovim/releases/latest/download/nvim.appimage
            chmod u+x nvim.appimage
            ./nvim.appimage
            echo "Set path to nvim.appimage in your shell configuration file."
            echo "For example: export PATH=\$PATH:$(pwd)/nvim.appimage"
        fi
    elif [ "$(uname)" = "Darwin" ]; then
        echo "Detected MacOS..."
        if ! command -v nvim >/dev/null 2>&1; then
            curl -LO https://github.com/neovim/neovim/releases/download/nightly/nvim-macos-x86_64.tar.gz
            tar xzf nvim-macos-x86_64.tar.gz
            ./nvim-macos-x86_64/bin/nvim
        fi
    else
        echo "Unsupported OS detected. This script supports Linux and MacOS only."
        exit 1
    fi
fi

# Homebrew
echo "Homebrew is a package manager for macOS and Linux. Would you like to install it?"
if prompt_install "Install Homebrew?"; then
    if ! command -v brew >/dev/null 2>&1; then
        echo "Installing Homebrew..."
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    else
        echo "Homebrew is already installed."
    fi

    if ! command -v brew >/dev/null 2>&1; then
        echo "Failed to configure Homebrew in PATH. Please add Homebrew to your PATH manually."
        exit 1
    else
        echo "Homebrew installed!"
        brew update
        brew upgrade
        brew upgrade --cask
        brew cleanup
    fi
fi

if ! command -v brew >/dev/null 2>&1; then
    echo "Homebrew is not installed. Skipping package and app installations."
    exit 1
fi

# Install packages
packages="python3 go rust node nvim bash zsh git tree fzf ack ripgrep gh gum glow"

echo "Install the following packages with Homebrew?"
echo "$packages"
if prompt_install "Install packages?"; then
    for package in $packages; do
        if brew list --formula | grep -q "^$package\$"; then
            echo "$package is already installed. Skipping..."
        else
            echo "Installing $package..."
            brew install "$package"
        fi
    done
fi

# Install apps
apps="google-chrome firefox rectangle postman"

echo "Install the following apps with Homebrew?"
echo "$apps"
if prompt_install "Install apps?"; then
    for app in $apps; do
        if brew list --cask | grep -q "^$app\$"; then
            echo "$app is already installed. Skipping..."
        else
            echo "Installing $app..."
            brew install --cask "$app"
        fi
    done
fi