#!/bin/bash

# exit immediately if a command exits with a non-zero status
set -e

#
# --- Helpers ---
#
command_exists() {
  command -v "$1" >/dev/null 2>&1
}

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

#
# --- OS Detection ---
#
is_macos() {
  [[ "$(uname)" == "Darwin" ]]
}

is_linux() {
  [[ "$(uname)" == "Linux" ]]
}

is_windows() {
  [[ "$(uname -o)" == "Msys" ]] || [[ "$(uname -o)" == "Cygwin" ]] || [[ "$(uname)" == "Windows" ]]
}

is_debian() {
    if is_linux; then
        if command_exists apt-get; then
            return 0
        fi
    fi
    return 1
}

#
# --- Package Managers ---
#
install_homebrew() {
  if ! command_exists brew; then
    echo "Installing Homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    if ! command_exists brew; then
      echo "Failed to install Homebrew."
      return 1
    fi
  else
    echo "Homebrew is already installed."
  fi
  brew update && brew upgrade && brew upgrade --cask && brew cleanup
}

install_chocolatey() {
  if ! command_exists choco; then
    echo "Installing Chocolatey..."
    powershell -NoProfile -ExecutionPolicy Bypass -Command "Set-ExecutionPolicy Bypass -Scope Process; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))"
    if ! command_exists choco; then
      echo "Failed to install Chocolatey."
      return 1
    fi
  else
    echo "Chocolatey is already installed."
  fi
  choco upgrade all -y
}

#
# --- Installs ---
#
install_xcode_cli() {
    if is_macos; then
        echo "Installing Xcode CLI tools..."
        xcode-select --install || true
    fi
}

install_apt_packages() {
  packages=("make" "gcc" "ripgrep" "unzip" "git" "xclip" "curl")
  sudo apt update
  sudo apt install -y "${packages[@]}"
}

install_neovim_macos() {
  if ! command_exists nvim; then
    curl -LO https://github.com/neovim/neovim/releases/download/nightly/nvim-macos.tar.gz
    tar xzf nvim-macos.tar.gz
    ./nvim-macos/bin/nvim
  fi
}

install_neovim_debian() {
  if ! command_exists nvim; then
    curl -LO https://github.com/neovim/neovim/releases/latest/download/nvim-linux-x86_64.tar.gz
    sudo rm -rf /opt/nvim-linux-x86_64
    sudo mkdir -p /opt/nvim-linux-x86_64
    sudo chmod a+rX /opt/nvim-linux-x86_64
    sudo tar -C /opt -xzf nvim-linux-x86_64.tar.gz
    sudo ln -sf /opt/nvim-linux-x86_64/bin/nvim /usr/local/bin/
  fi
}

install_packages_macos() {
    packages="go rust node nvim starship bash zsh git tree fzf ack ripgrep gh gum glow stow"
    echo "Install the following packages with Homebrew?"
    echo "$packages"
    if prompt_install "Install packages?"; then
        for package in $packages; do
            brew install "$package"
        done
    fi
}

install_apps_macos() {
    apps="rectangle postman"
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

install_packages_debian() {
    packages="go rust node neovim starship bash zsh git tree fzf ack ripgrep gh gum glow stow"
    echo "Install the following packages with apt?"
    echo "$packages"
    if prompt_install "Install packages?"; then
        sudo apt update
        sudo apt install -y $packages
    fi
}

install_packages_windows() {
    packages="go rust node neovim starship bash zsh git tree fzf ack ripgrep gh gum glow stow"
    echo "Install the following packages with choco?"
    echo "$packages"
    if prompt_install "Install packages?"; then
        for package in $packages; do
            if choco list --local-only | grep -q "^$package\$"; then
                echo "$package is already installed. Skipping..."
            else
                echo "Installing $package..."
                choco install "$package" -y
            fi
        done
    fi
}


#
# --- Main ---
#
main() {
  if is_macos; then
    install_xcode_cli
    install_homebrew
    install_packages_macos
    install_neovim_macos
    install_apps_macos
  elif is_windows; then
    install_chocolatey
    install_packages_windows
  elif is_debian; then
    install_packages_debian
    install_neovim_debian
  else
    echo "Unsupported OS."
    return 1
  fi
}

main "$@"
