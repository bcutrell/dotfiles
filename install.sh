#!/usr/bin/env zsh

# Resources
# https://sourabhbajaj.com/mac-setup/

# Mac CLI tools
xcode-select --install

# Homebrew 
if ! command -v brew &>/dev/null; then
    echo "Installing Homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
else
    echo "Homebrew is already installed."
fi

if ! command -v brew &>/dev/null; then
    echo "Failed to configure Homebrew in PATH. Please add Homebrew to your PATH manually."
    exit 1
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
    "nvim"
    "bash"
    "zsh"
    "git"
    "tree"
    "fzf"
    "ack"
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
