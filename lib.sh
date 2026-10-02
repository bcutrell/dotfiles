# Shared helpers for setup.sh and clean.sh. POSIX sh.
# shellcheck shell=sh

if [ -t 1 ] && [ -z "${NO_COLOR:-}" ]; then
    C_RESET=$(printf '\033[0m'); C_DIM=$(printf '\033[2m')
    C_RED=$(printf '\033[31m'); C_GRN=$(printf '\033[32m'); C_YEL=$(printf '\033[33m')
else
    C_RESET=''; C_DIM=''; C_RED=''; C_GRN=''; C_YEL=''
fi

log()  { printf '%s\n' "  $*"; }
step() { printf '%s==>%s %s\n' "$C_GRN" "$C_RESET" "$*"; }
warn() { printf '%swarn:%s %s\n' "$C_YEL" "$C_RESET" "$*" >&2; }
die()  { printf '%serror:%s %s\n' "$C_RED" "$C_RESET" "$*" >&2; exit 1; }
have() { command -v "$1" >/dev/null 2>&1; }

# confirm <prompt> [default y|n]; ASSUME_YES=1 takes the default.
confirm() {
    _def=${2:-y}
    if [ "${ASSUME_YES:-0}" = 1 ]; then [ "$_def" = y ]; return; fi
    if [ "$_def" = y ]; then _hint='[Y/n]'; else _hint='[y/N]'; fi
    while :; do
        printf '%s %s ' "$1" "$_hint"
        read -r _ans || { echo; [ "$_def" = y ]; return; }
        [ -z "$_ans" ] && _ans=$_def
        case "$_ans" in
            y|Y|yes|YES) return 0 ;;
            n|N|no|NO)   return 1 ;;
            *) echo "Please answer y or n." ;;
        esac
    done
}

# ask <prompt> <default> -> echoes the answer
ask() {
    if [ "${ASSUME_YES:-0}" = 1 ]; then printf '%s' "$2"; return; fi
    printf '%s [%s] ' "$1" "$2" >&2
    read -r _a || _a=''
    [ -z "$_a" ] && _a=$2
    printf '%s' "$_a"
}

os() {
    case "$(uname -s)" in
        Darwin) echo macos ;;
        Linux)  if have apt-get; then echo debian; else echo unsupported; fi ;;
        *)      echo unsupported ;;
    esac
}

# Normalized to the names Neovim uses in its release assets.
arch() {
    case "$(uname -m)" in
        x86_64|amd64)  echo x86_64 ;;
        arm64|aarch64) echo arm64 ;;
        *) uname -m ;;
    esac
}

# manifest [tier] -> "<repo path> <$HOME path>" lines. No tier = every entry.
# The allowlist of everything that may be linked into $HOME.
manifest() {
    _want=${1:-}
    while read -r _tier _src _dst; do
        [ -z "$_tier" ] && continue
        if [ -z "$_want" ] || [ "$_tier" = both ] || [ "$_tier" = "$_want" ]; then
            printf '%s %s\n' "$_src" "$_dst"
        fi
    done <<'EOF'
both     shell/.zshrc                  .zshrc
both     shell/.bashrc                 .bashrc
both     shell/.aliases                .aliases
both     git/.gitconfig                .gitconfig
both     git/.gitignore_global         .gitignore_global
both     tmux/.tmux.conf               .tmux.conf
minimal  vim-light/.vimrc              .vimrc
full     vim/.vimrc                    .vimrc
full     nvim/.config/nvim             .config/nvim
full     config/.config/starship.toml  .config/starship.toml
EOF
}

BACKUP_ROOT="$HOME/.dotfiles_backup"

# is_our_link <$HOME-relative dst> <repo-relative src>; needs $REPO.
is_our_link() { [ -L "$HOME/$1" ] && [ "$(resolve_link "$HOME/$1")" = "$REPO/$2" ]; }

# resolve_link <symlink> -> absolute target (old stow links are relative).
resolve_link() {
    _t=$(readlink "$1") || return 1
    case "$_t" in /*) printf '%s' "$_t"; return 0 ;; esac
    _d=$(CDPATH='' cd -- "$(dirname -- "$1")/$(dirname -- "$_t")" 2>/dev/null && pwd) || return 1
    printf '%s/%s' "$_d" "$(basename -- "$_t")"
}
