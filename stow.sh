#!/bin/bash

set -e

PACKAGES=(
    "config"
    "git"
    "nvim"
    "shell"
    "vim"
)

check_stow() {
    if ! command -v stow >/dev/null 2>&1; then
        echo "GNU Stow is required but not installed"
        exit 1
    fi
}

backup_configs() {
    local backup_dir="$HOME/.dotfiles_backup/$(date +%Y%m%d_%H%M%S)"
    echo "Creating backup directory: $backup_dir"
    mkdir -p "$backup_dir"
    
    for package in "${PACKAGES[@]}"; do
        echo "Checking package: $package"
        stow -nvt "$HOME" "$package" 2>&1 | grep "LINK:" | while read -r line; do
            file=$(echo "$line" | awk '{print $NF}')
            if [ -e "$HOME/$file" ] && [ ! -L "$HOME/$file" ]; then
                mkdir -p "$(dirname "$backup_dir/$file")"
                cp -a "$HOME/$file" "$backup_dir/$file"
                echo "Backed up: $file"
            fi
        done
    done
}

stow_packages() {
    local action=$1
    local dry_run=$2
    local stow_flags=""
    
    case "$action" in
        "install")
            if [ "$dry_run" = "true" ]; then
                stow_flags="-nvRt"
                echo "Performing dry run for install..."
            else
                stow_flags="-vRt"
            fi
            ;;
        "remove")
            if [ "$dry_run" = "true" ]; then
                stow_flags="-nvDt"
                echo "Performing dry run for remove..."
            else
                stow_flags="-vDt"
            fi
            ;;
        *)
            echo "Invalid action: $action"
            exit 1
            ;;
    esac
    
    for package in "${PACKAGES[@]}"; do
        echo "Processing package: $package"
        stow $stow_flags "$HOME" "$package"
    done
}

list_packages() {
    echo "Available packages:"
    for package in "${PACKAGES[@]}"; do
        echo "  - $package"
    done
}

usage() {
    echo "Usage: $0 [install|remove|list] [--dry-run]"
    echo
    echo "Commands:"
    echo "  install    Install (stow) all packages"
    echo "  remove     Remove (unstow) all packages"
    echo "  list       List available packages"
    echo
    echo "Options:"
    echo "  --dry-run  Show what would be done without making changes"
    exit 1
}

main() {
    local command=$1
    local dry_run=false
    
    [ $# -eq 0 ] && usage
    
    if [ "$2" = "--dry-run" ]; then
        dry_run=true
    fi
    
    case "$command" in
        "install")
            check_stow
            if [ "$dry_run" = "false" ]; then
                backup_configs
            fi
            stow_packages "install" "$dry_run"
            ;;
        "remove")
            check_stow
            stow_packages "remove" "$dry_run"
            ;;
        "list")
            list_packages
            ;;
        *)
            usage
            ;;
    esac
}

main "$@"
