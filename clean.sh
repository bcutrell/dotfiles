#!/bin/sh
# Teardown helpers.  Usage: sh clean.sh <brew|cache|unlink|doctor|all>
set -eu

REPO=$(CDPATH='' cd -- "$(dirname -- "$0")" && pwd)
cd "$REPO"
. "$REPO/lib.sh"

OS=$(os)

usage() {
    cat <<'EOF'
Usage: sh clean.sh <command>

  brew     Uninstall Linuxbrew/Homebrew, strip `brew shellenv` from rc files.
  cache    Show sizes and remove build/tool caches (per-item confirm).
  unlink   Remove every symlink this repo created, restore newest backup.
  doctor   Same report as `setup.sh --check`.
  all      cache, then unlink.
EOF
}

# size <path> -> human size, or empty if absent
size_of() {
    [ -e "$1" ] || return 1
    _s=$(du -sh "$1" 2>/dev/null) || return 1
    _s=${_s%%	*}                 # drop the path (du separates with a tab)
    while :; do case $_s in ' '*) _s=${_s# } ;; *) break ;; esac; done
    printf '%s' "$_s"             # ...and BSD du left-pads the size
}

size_line() { printf '  %-38s %6s   ' "$1" "$2"; }

# offer <path> <label>
offer() {
    _sz=$(size_of "$1") || return 0
    size_line "$2" "$_sz"
    if confirm 'remove?' n; then
        rm -rf "$1"
        log "removed $1"
    fi
}

cmd_brew() {
    step "Homebrew / Linuxbrew"
    _prefix=''
    for p in /home/linuxbrew/.linuxbrew "$HOME/.linuxbrew" /opt/homebrew /usr/local/Homebrew; do
        [ -d "$p" ] && { _prefix=$p; break; }
    done
    if [ -z "$_prefix" ]; then
        log "no brew installation found"
    else
        log "found $_prefix ($(size_of "$_prefix" || echo '?'))"
        case $_prefix in /opt/homebrew|/usr/local/Homebrew)
            warn "that is a macOS Homebrew prefix -- the full tier depends on it" ;;
        esac
        if confirm "Run the official Homebrew uninstaller on $_prefix?" n; then
            _u=$(mktemp)
            curl -fsSL -o "$_u" https://raw.githubusercontent.com/Homebrew/install/HEAD/uninstall.sh
            /bin/bash "$_u" --path="$_prefix" || warn "uninstaller exited non-zero"
            rm -f "$_u"
        fi
    fi

    step "Stripping brew shellenv from rc files"
    for rc in "$HOME/.zshrc" "$HOME/.bashrc" "$HOME/.profile" "$HOME/.bash_profile" "$HOME/.zprofile"; do
        [ -f "$rc" ] || continue
        grep -q 'brew shellenv' "$rc" 2>/dev/null || continue
        if [ -L "$rc" ]; then
            warn "$rc is a symlink into the repo -- edit it there, not here"
            continue
        fi
        cp "$rc" "$rc.bak"
        grep -v 'brew shellenv' "$rc.bak" > "$rc"
        log "cleaned $rc (original at $rc.bak)"
    done
}

cmd_cache() {
    step "Caches"
    offer "$HOME/.cache/pip"                  "pip cache"
    offer "$HOME/.npm/_cacache"               "npm cache"
    offer "$HOME/.cache/Homebrew"             "Homebrew cache"
    offer "$HOME/.cache/go-build"             "Go build cache"
    offer "$HOME/.local/share/nvim/lazy"      "nvim plugins (lazy.nvim)"
    offer "$HOME/.local/share/nvim/mason"     "nvim LSP servers (mason)"
    offer "$HOME/.cache/nvim"                 "nvim cache"
    offer "$HOME/.vim/plugged"                "vim plugins (vim-plug)"
    # Generated starship/fzf init; the rc files rebuild these on next shell.
    offer "$HOME/.cache/zsh"                  "zsh init cache"
    offer "$HOME/.cache/bash"                 "bash init cache"

    if [ "$OS" = debian ]; then
        size_line "apt cache" "$(size_of /var/cache/apt || echo '?')"
        confirm 'clean?' n && { sudo apt-get clean; sudo apt-get autoremove -y -qq; log "apt cleaned"; }
    fi

    _b=$BACKUP_ROOT
    if [ -d "$_b" ]; then
        step "Old dotfiles backups"
        # Timestamped names sort lexically = chronologically, so a glob gives
        # them in order and the last one is the newest. No ls/wc/sed forks.
        set -- "$_b"/*
        [ -e "$1" ] || set --
        log "$# backup(s), $(size_of "$_b" || echo 0) total -- keeping the newest"
        while [ $# -gt 1 ]; do
            offer "$1" "backup $(basename "$1")"
            shift
        done
    fi
}

cmd_unlink() {
    step "Unlinking"
    # No tier argument: every entry this repo could ever own.
    manifest | while read -r src dst; do
        if is_our_link "$dst" "$src"; then
            rm "$HOME/$dst"; log "removed ~/$dst"
        fi
    done

    _b=$BACKUP_ROOT
    set -- "$_b"/*
    if [ -e "$1" ]; then eval "_latest=\${$#}"; _latest=$(basename "$_latest"); else _latest=''; fi
    if [ -n "$_latest" ] && confirm "Restore the most recent backup ($_latest)?" y; then
        step "Restoring $_b/$_latest"
        (cd "$_b/$_latest" && find . -mindepth 1 -maxdepth 2 \( -type f -o -type d \) -print) \
        | sed 's|^\./||' | while read -r f; do
            [ -e "$_b/$_latest/$f" ] || continue
            [ -d "$_b/$_latest/$f" ] && [ ! -e "$HOME/$f" ] && continue
            if [ -e "$HOME/$f" ]; then
                warn "~/$f exists, not overwriting"
            else
                mkdir -p "$(dirname "$HOME/$f")"
                cp -a "$_b/$_latest/$f" "$HOME/$f"
                log "restored ~/$f"
            fi
        done
    fi

    step "Dangling symlinks in \$HOME"
    find "$HOME" -maxdepth 2 -type l ! -exec test -e {} \; -print 2>/dev/null || true
}

case "${1:-}" in
    brew)   cmd_brew ;;
    cache)  cmd_cache ;;
    unlink) cmd_unlink ;;
    doctor) sh "$REPO/setup.sh" --check ;;
    all)    cmd_cache; cmd_unlink ;;
    ''|--help|-h) usage; [ -z "${1:-}" ] && exit 2 || exit 0 ;;
    *) printf 'Unknown command: %s\n\n' "$1" >&2; usage >&2; exit 2 ;;
esac
