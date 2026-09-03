#!/bin/sh
# Dotfiles setup. Usage:  sh setup.sh [--minimal|--full] [--link-only] [--yes] [--check]
set -eu

REPO=$(CDPATH='' cd -- "$(dirname -- "$0")" && pwd)
cd "$REPO"
. "$REPO/lib.sh"

TIER=''
ASSUME_YES=0
CHECK_ONLY=0
DO_PKGS=1
DO_LINK=1
UNAME_S=$(uname -s); UNAME_M=$(uname -m); UNAME_R=$(uname -r)
OS=$(os)
ARCH=$(arch)

usage() {
    cat <<'EOF'
Usage: sh setup.sh [options]

  --minimal   VMs, weak boxes, servers. git, curl, tmux, vim (no plugins).
              No Node, no Neovim, no Homebrew.
  --full      Workstation. Everything above plus Neovim + LSP, Node,
              fzf, ripgrep, starship.
  --link-only Skip package installation; only link dotfiles.
  --yes       Non-interactive; accept every default.
  --check     Report OS, tier, tools and link status. Changes nothing.
  --help      This message.

With no tier flag, setup.sh asks.
EOF
}

while [ $# -gt 0 ]; do
    case "$1" in
        --minimal) TIER=minimal ;;
        --link-only) DO_PKGS=0 ;;
        --full)    TIER=full ;;
        --yes|-y)  ASSUME_YES=1 ;;
        --check)   CHECK_ONLY=1 ;;
        --help|-h) usage; exit 0 ;;
        *) printf 'Unknown option: %s\n\n' "$1" >&2; usage >&2; exit 2 ;;
    esac
    shift
done
export ASSUME_YES

# ---------------------------------------------------------------- doctor

link_status() {
    _dst="$HOME/$2"
    if [ -L "$_dst" ]; then
        if is_our_link "$2" "$1"; then echo ok
        elif [ -e "$_dst" ]; then echo "points elsewhere"
        else echo DANGLING; fi
    elif [ -e "$_dst" ]; then echo "unmanaged file"
    else echo "not linked"; fi
}

doctor() {
    step "System"
    log "os        $OS ($UNAME_S $UNAME_R)"
    log "arch      $ARCH"
    log "shell     ${SHELL:-?}"
    log "repo      $REPO"

    step "Tools"
    for t in git curl tmux vim nvim zsh node rg fzf bat starship; do
        if _p=$(command -v "$t"); then
            printf '  %-10s %sok%s  %s\n' "$t" "$C_GRN" "$C_RESET" "$_p"
        else
            printf '  %-10s %s--%s  not installed\n' "$t" "$C_DIM" "$C_RESET"
        fi
    done

    step "Links"
    manifest | while read -r src dst; do
        printf '  %-24s %-30s %s\n' "~/$dst" "$src" "$(link_status "$src" "$dst")"
    done

    if [ -d "$BACKUP_ROOT" ]; then
        step "Backups"
        for d in "$BACKUP_ROOT"/*; do [ -e "$d" ] && log "$d"; done
    fi
}

if [ "$CHECK_ONLY" = 1 ]; then doctor; exit 0; fi

# ---------------------------------------------------------------- prompts

[ "$OS" = unsupported ] && die "unsupported OS: $UNAME_S. This repo targets macOS and Debian/Ubuntu."

if [ -z "$TIER" ]; then
    if [ "$ASSUME_YES" = 1 ]; then
        TIER=minimal
    else
        cat <<'EOF'

  1) minimal   VMs, weak boxes, servers
               git, curl, tmux, vim (no plugins). No Node/Neovim/Homebrew.
  2) full      Workstation
               adds Neovim & LSP, Node, fzf, ripgrep, starship

EOF
        while [ -z "$TIER" ]; do
            case "$(ask '  Choice?' 1)" in
                1|minimal|'') TIER=minimal ;;   # Enter or EOF: safe default
                2|full)       TIER=full ;;
                *) echo "  Enter 1 or 2." ;;
            esac
        done
        echo
    fi
fi

confirm "Link dotfiles into $HOME?" y || DO_LINK=0
if [ "$DO_PKGS" = 1 ]; then
    confirm "Install packages for the $TIER tier?" y || DO_PKGS=0
fi

GIT_NAME=''; GIT_EMAIL=''
if [ ! -f "$HOME/.gitconfig.local" ] && confirm "Set your git identity?" y; then
    GIT_NAME=$(ask '  git user.name '  "$(git config --global user.name  2>/dev/null || echo 'Ben Cutrell')")
    GIT_EMAIL=$(ask '  git user.email' "$(git config --global user.email 2>/dev/null || echo 'bcutrell13@gmail.com')")
fi

# ---------------------------------------------------------------- packages

# install_missing <label> <list-cmd> <install-fn> <pkg>...
# One place that filters a package list down to what is actually missing.
install_missing() {
    _label=$1; _list=$2; _inst=$3; shift 3
    # One query for the whole set, then a fork-free membership test per package.
    _have=" $($_list 2>/dev/null | tr '\n' ' ') "
    _missing=''
    for p in "$@"; do
        case "$_have" in *" $p "*) ;; *) _missing="$_missing $p" ;; esac
    done
    if [ -z "$_missing" ]; then log "all $_label already present"; return; fi
    log "installing:$_missing"
    # shellcheck disable=SC2086
    "$_inst" $_missing
}

apt_list()  { dpkg-query -W -f '${binary:Package}\n'; }
apt_do()    { sudo apt-get update -qq; sudo apt-get install -y -qq "$@"; }
brew_list() { brew list --formula; }
brew_do()   { brew install "$@"; }
cask_list() { brew list --cask; }
cask_do()   { brew install --cask "$@"; }

install_neovim_tarball() {
    have nvim && { log "neovim already installed"; return; }
    case "$OS" in
        macos) _asset="nvim-macos-$ARCH" ;;
        *)     _asset="nvim-linux-$ARCH" ;;
    esac
    _url="https://github.com/neovim/neovim/releases/latest/download/$_asset.tar.gz"
    _tmp=$(mktemp -d)
    log "downloading $_asset"
    curl -fsSL -o "$_tmp/nvim.tar.gz" "$_url" \
        || { rm -rf "$_tmp"; warn "could not fetch $_url -- skipping neovim"; return; }
    sudo rm -rf "/opt/$_asset"
    sudo tar -C /opt -xzf "$_tmp/nvim.tar.gz"
    sudo ln -sf "/opt/$_asset/bin/nvim" /usr/local/bin/nvim
    rm -rf "$_tmp"
    log "neovim installed to /opt/$_asset"
}

install_macos() {
    if ! xcode-select -p >/dev/null 2>&1; then
        step "Xcode command line tools"
        xcode-select --install || true
        log "finish the GUI installer, then re-run this script"
    fi

    # Minimal never installs Homebrew (far too slow); git and vim come with the
    # Xcode command line tools.
    if [ "$TIER" = minimal ]; then
        step "Packages"
        if have brew; then
            install_missing "brew formulae" brew_list brew_do git tmux
        else
            log "Homebrew not present -- skipping, minimal never installs it"
        fi
        return
    fi

    if ! have brew; then
        step "Homebrew"
        if ! confirm "Install Homebrew? (large download)" y; then
            install_neovim_tarball   # no brew: fall back to the release tarball
            return 0
        fi
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
        have brew || die "Homebrew install failed"
    fi
    step "Packages (brew)"
    # No `brew upgrade`/`cleanup` here -- it ran on every invocation before and
    # was the slowest thing in the repo.
    install_missing "brew formulae" brew_list brew_do \
        git curl wget tmux zsh neovim node go rust ripgrep fd fzf bat \
        gh tree starship gum glow

    if confirm "Install GUI apps (rectangle, postman)?" n; then
        install_missing "casks" cask_list cask_do rectangle postman
    fi
}

install_debian() {
    if [ "$TIER" = minimal ]; then
        step "Packages (apt, minimal)"
        install_missing "apt packages" apt_list apt_do ca-certificates git curl tmux vim
        return
    fi
    step "Packages (apt, full)"
    install_missing "apt packages" apt_list apt_do \
        ca-certificates build-essential git curl wget unzip tmux zsh \
        ripgrep fd-find bat fzf python3 python3-pip

    if ! have node; then
        step "Node.js LTS"
        if confirm "Install Node LTS from NodeSource?" y; then
            curl -fsSL https://deb.nodesource.com/setup_lts.x | sudo -E bash -
            sudo apt-get install -y -qq nodejs
        fi
    fi

    step "Neovim"
    install_neovim_tarball

    if ! have starship; then
        step "Starship"
        confirm "Install starship prompt?" y && curl -sS https://starship.rs/install.sh | sh -s -- -y
    fi
}

if [ "$DO_PKGS" = 1 ]; then
    case "$OS" in
        macos)  install_macos ;;
        debian) install_debian ;;
    esac
fi

# ---------------------------------------------------------------- linking

BACKUP="$BACKUP_ROOT/$(date +%Y%m%d_%H%M%S)"

link() {
    _src="$REPO/$1"; _dst="$HOME/$2"
    [ -e "$_src" ] || { warn "missing in repo: $1"; return; }
    if [ -L "$_dst" ]; then
        is_our_link "$2" "$1" && { log "ok       ~/$2"; return; }
        rm "$_dst"
    elif [ -e "$_dst" ]; then
        mkdir -p "$(dirname "$BACKUP/$2")"
        mv "$_dst" "$BACKUP/$2"
        log "backed up ~/$2"
    fi
    mkdir -p "$(dirname "$_dst")"
    ln -s "$_src" "$_dst"
    log "linked   ~/$2"
}

if [ "$DO_LINK" = 1 ]; then
    step "Linking dotfiles ($TIER)"
    manifest "$TIER" | while read -r src dst; do
        link "$src" "$dst"
    done
    [ -d "$BACKUP" ] && log "backups in $BACKUP"
fi

# ---------------------------------------------------------------- git local

if [ -n "$GIT_NAME" ] || [ ! -f "$HOME/.gitconfig.local" ]; then
    step "Writing ~/.gitconfig.local"
    {
        echo "# Machine-local git settings. Not tracked in the dotfiles repo."
        if [ -n "$GIT_NAME" ]; then
            echo "[user]"
            echo "	name = $GIT_NAME"
            echo "	email = $GIT_EMAIL"
        fi
        echo "[credential]"
        if [ "$OS" = macos ]; then
            echo "	helper = osxkeychain"
        else
            echo "	helper = cache --timeout=3600"
        fi
    } > "$HOME/.gitconfig.local"
    log "credential helper set for $OS"
fi

# ---------------------------------------------------------------- done

step "Done ($TIER)"
echo
log "Restart your shell (or: exec \$SHELL)"
if [ "$TIER" = full ]; then
    log "Run nvim -- lazy.nvim installs plugins on first launch"
    log "Then :checkhealth, and :Mason for language servers"
else
    log "vim is configured with no plugins and no network calls"
    log "sh setup.sh --full   upgrades this box later"
fi
log "sh clean.sh doctor   shows what is installed and linked"
echo
