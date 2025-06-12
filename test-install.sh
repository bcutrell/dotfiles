#!/bin/bash

# Test version of install.sh that shows what would be done without actually doing it
set -e

# Enable dry run mode
DRY_RUN=${DRY_RUN:-true}
VERBOSE=${VERBOSE:-true}

log_action() {
    if [[ "$VERBOSE" == "true" ]]; then
        echo "[DRY RUN] $1"
    fi
}

safe_run() {
    if [[ "$DRY_RUN" == "true" ]]; then
        log_action "Would run: $*"
    else
        echo "Running: $*"
        "$@"
    fi
}

command_exists() {
    command -v "$1" >/dev/null 2>&1
}

prompt_install() {
    if [[ "$DRY_RUN" == "true" ]]; then
        log_action "Would prompt: $1"
        return 0  # Always yes in dry run
    else
        while true; do
            read -rp "$1 (y/n) " choice
            case "$choice" in
            y | Y) return 0 ;;
            n | N) return 1 ;;
            *) echo "Please answer y or n." ;;
            esac
        done
    fi
}

# Test OS detection
is_macos() {
    [[ "$(uname)" == "Darwin" ]]
}

is_linux() {
    [[ "$(uname)" == "Linux" ]]
}

is_debian() {
    if is_linux; then
        if command_exists apt-get; then
            return 0
        fi
    fi
    return 1
}

# Test package installation functions
install_homebrew() {
    if ! command_exists brew; then
        log_action "Would install Homebrew"
    else
        log_action "Homebrew already installed"
    fi
    log_action "Would run: brew update && brew upgrade"
}

install_minimal_packages_macos() {
    packages="nvim git curl unzip make gcc node ripgrep stow"
    log_action "Would install minimal packages: $packages"
    for package in $packages; do
        if command_exists "$package"; then
            log_action "$package already installed"
        else
            log_action "Would install: $package"
        fi
    done
}

install_minimal_packages_debian() {
    packages="make gcc ripgrep unzip git curl stow nodejs npm"
    log_action "Would install minimal packages: $packages"
    log_action "Would run: sudo apt update"
    log_action "Would run: sudo apt install -y $packages"
}

install_neovim_debian() {
    if ! command_exists nvim; then
        log_action "Would download and install Neovim from GitHub releases"
    else
        log_action "Neovim already installed"
    fi
}

setup_neovim() {
    log_action "Would create ~/.config/nvim directory"
    log_action "Would create ~/docs/vimwiki directory"
}

test_script_logic() {
    echo "=== Testing Script Logic ==="
    echo "OS Detection:"
    echo "  macOS: $(is_macos && echo "YES" || echo "NO")"
    echo "  Linux: $(is_linux && echo "YES" || echo "NO")"
    echo "  Debian: $(is_debian && echo "YES" || echo "NO")"
    echo
    
    echo "Command Detection:"
    for cmd in brew nvim git node npm ripgrep stow curl unzip make gcc; do
        echo "  $cmd: $(command_exists "$cmd" && echo "FOUND" || echo "MISSING")"
    done
    echo
}

main() {
    local install_type="${1:-full}"
    
    echo "=== DRY RUN MODE ==="
    echo "Set DRY_RUN=false to actually run commands"
    echo "Install type: $install_type"
    echo
    
    test_script_logic
    
    echo "=== Installation Simulation ==="
    
    if is_macos; then
        log_action "Detected macOS"
        install_homebrew
        if [[ "$install_type" == "minimal" ]]; then
            install_minimal_packages_macos
        fi
    elif is_debian; then
        log_action "Detected Debian/Ubuntu"
        if [[ "$install_type" == "minimal" ]]; then
            install_minimal_packages_debian
        fi
        install_neovim_debian
    else
        log_action "Unsupported OS detected"
    fi
    
    setup_neovim
    
    echo
    echo "=== Test Complete ==="
}

main "$@"
