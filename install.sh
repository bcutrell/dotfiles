#!/bin/bash

set -e

# Function to check if we're on macOS
is_macos() {
    [ "$(uname)" = "Darwin" ]
}

# Function to check if we're on Linux
is_linux() {
    [ "$(uname)" = "Linux" ]
}

# Function to prompt user for installation
prompt_install() {
    while true; do
        read -rp "$1 (y/n) " choice
        case "$choice" in
            y|Y ) return 0;;
            n|N ) return 1;;
            * ) echo "Please answer y or n.";;
        esac
    done
}

# Function to install Homebrew
install_homebrew() {
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
            return 1
        else
            echo "Homebrew installed!"
            brew update
            brew upgrade
            brew upgrade --cask
            brew cleanup
        fi
    fi
}

# Function to check Homebrew installation
check_homebrew() {
    if ! command -v brew >/dev/null 2>&1; then
        echo "Homebrew is not installed. Installing Homebrew first."
        install_homebrew
    else
        echo "Homebrew is already installed."
    fi
}

# Function to install Xcode CLI tools on macOS
install_xcode_cli() {
    if is_macos; then
        echo "Installing Xcode CLI tools..."
        xcode-select --install || true
    fi
}

# Function to install rye
install_rye() {
    echo "rye is a python package manager. Would you like to install it?"
    if prompt_install "Install rye?"; then
        curl -sSf https://rye-up.com/get | bash
        echo "rye installed!"
    else
        echo "Skipping rye installation."
    fi
}

# Function to install starship
install_starship() {
    echo "starship is a cross-shell prompt. Would you like to install it?"
    if prompt_install "Install starship?"; then
        if ! command -v starship >/dev/null 2>&1; then
            sh -c "$(curl -fsSL https://starship.rs/install.sh)"
        else
            echo "starship is already installed."
        fi
    fi
}

# Function to install neovim
install_neovim() {
    echo "neovim is a hyperextensible text editor based on Vim. Would you like to install it without using Homebrew?"
    if prompt_install "Install neovim without Homebrew?"; then
        if is_linux; then
            echo "Detected Linux OS..."
            if ! command -v nvim >/dev/null 2>&1; then
                curl -LO https://github.com/neovim/neovim/releases/latest/download/nvim.appimage
                chmod u+x nvim.appimage
                ./nvim.appimage
                echo "Set path to nvim.appimage in your shell configuration file."
                echo "For example: export PATH=\$PATH:$(pwd)/nvim.appimage"
            fi
        elif is_macos; then
            echo "Detected macOS..."
            if ! command -v nvim >/dev/null 2>&1; then
                curl -LO https://github.com/neovim/neovim/releases/download/nightly/nvim-macos.tar.gz
                tar xzf nvim-macos.tar.gz
                ./nvim-macos/bin/nvim
            fi
        else
            echo "Unsupported OS detected. This script supports Linux and macOS only."
            return 1
        fi
    fi
}

# Function to install Homebrew packages
install_packages() {
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
}

# Function to install Homebrew cask apps
install_apps() {
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
}

# Main execution
main() {
    install_xcode_cli
    check_homebrew
    install_rye
    install_starship
    install_neovim
    install_packages
    install_apps
}

main "$@"
