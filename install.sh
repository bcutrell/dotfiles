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
        y | Y) return 0 ;;
        n | N) return 1 ;;
        *) echo "Please answer y or n." ;;
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
# --- macos installs ---
#
install_xcode_cli() {
    if is_macos; then
        echo "Installing Xcode CLI tools..."
        xcode-select --install || true
    fi
}

install_neovim_macos() {
    if ! command_exists nvim; then
        echo "Installing Neovim..."
        curl -LO https://github.com/neovim/neovim/releases/download/nightly/nvim-macos.tar.gz
        tar xzf nvim-macos.tar.gz
        sudo mv nvim-macos /opt/
        sudo ln -sf /opt/nvim-macos/bin/nvim /usr/local/bin/nvim
        rm nvim-macos.tar.gz
        echo "Neovim installed successfully"
    else
        echo "Neovim is already installed."
    fi
}

install_packages_macos() {
    # Core packages needed for the dotfiles setup
    packages="go rust node nvim starship bash zsh git tree fzf ack ripgrep gh gum glow stow bat"
    echo "Install the following packages with Homebrew?"
    echo "$packages"
    if prompt_install "Install packages?"; then
        for package in $packages; do
            if brew list | grep -q "^$package\$"; then
                echo "$package is already installed. Skipping..."
            else
                echo "Installing $package..."
                brew install "$package"
            fi
        done
    fi
    
    # Additional development tools (optional)
    dev_packages="make gcc unzip curl wget"
    echo "Install additional development tools?"
    echo "$dev_packages"
    if prompt_install "Install dev tools?"; then
        for package in $dev_packages; do
            if brew list | grep -q "^$package\$"; then
                echo "$package is already installed. Skipping..."
            else
                echo "Installing $package..."
                brew install "$package"
            fi
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

#
# --- debian installs ---
#
install_neovim_debian() {
    if ! command_exists nvim; then
        echo "Installing Neovim..."
        curl -LO https://github.com/neovim/neovim/releases/latest/download/nvim-linux-x86_64.tar.gz
        sudo rm -rf /opt/nvim-linux-x86_64
        sudo mkdir -p /opt/nvim-linux-x86_64
        sudo chmod a+rX /opt/nvim-linux-x86_64
        sudo tar -C /opt -xzf nvim-linux-x86_64.tar.gz
        sudo ln -sf /opt/nvim-linux-x86_64/bin/nvim /usr/local/bin/
        rm nvim-linux-x86_64.tar.gz
        echo "Neovim installed successfully"
    else
        echo "Neovim is already installed."
    fi
}

install_starship_debian() {
    if ! command_exists starship; then
        echo "Installing Starship..."
        curl -sS https://starship.rs/install.sh | sh
    else
        echo "Starship is already installed."
    fi
}

install_packages_debian() {
    # Core packages
    packages="make gcc ripgrep unzip git curl wget stow nodejs npm python3 python3-pip bat"
    echo "Install the following packages with apt?"
    echo "$packages"
    if prompt_install "Install packages?"; then
        sudo apt update
        sudo apt install -y $packages
    fi
    
    # Install Node.js LTS if not already installed
    if ! command_exists node; then
        echo "Installing Node.js LTS..."
        curl -fsSL https://deb.nodesource.com/setup_lts.x | sudo -E bash -
        sudo apt-get install -y nodejs
    fi
}

#
# --- windows installs ---
#
install_packages_windows() {
    packages="make mingw ripgrep unzip git curl stow nodejs python bat"
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
# --- Post-install setup ---
#
setup_neovim() {
    echo "Setting up Neovim..."
    
    # Create necessary directories
    mkdir -p ~/.config/nvim
    mkdir -p ~/docs/vimwiki
    
    echo "Neovim setup complete."
    echo "After stowing configs, run 'nvim' and plugins will auto-install via lazy.nvim"
    echo "Use ':checkhealth' in Neovim to verify everything is working"
}

print_next_steps() {
    echo ""
    echo "=== Installation Complete ==="
    echo ""
    echo "Next steps:"
    echo "1. Run './stow.sh install' to link configuration files"
    echo "2. Restart your terminal or run 'source ~/.zshrc' (or ~/.bashrc)"
    echo "3. Open Neovim with 'nvim' - plugins will auto-install"
    echo "4. In Neovim, run ':checkhealth' to verify setup"
    echo "5. Run ':Mason' to manage LSP servers"
    echo ""
    echo "Optional:"
    echo "- Install a Nerd Font for better icons: https://www.nerdfonts.com/"
    echo "- Set vim.g.have_nerd_font = true in nvim config if using Nerd Font"
    echo ""
}

#
# --- Main ---
#
main() {
    echo "Starting dotfiles installation..."
    
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
        install_starship_debian
    else
        echo "Unsupported OS."
        return 1
    fi
    
    setup_neovim
    print_next_steps
}

main "$@"