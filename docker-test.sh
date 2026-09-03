#!/bin/bash
# Test setup.sh in Debian and Ubuntu containers.
# Usage: ./docker-test.sh <build|test|test-full|test-nvim|shell|cleanup|all> [debian|ubuntu|both]
set -uo pipefail

# Reuse the repo's own log/colour helpers (they honour NO_COLOR and non-tty).
. "$(dirname "$0")/lib.sh"
ok()   { echo "${C_GRN}PASS${C_RESET} $*"; }
fail() { echo "${C_RED}FAIL${C_RESET} $*"; FAILED=1; }
FAILED=0

# Assertion vocabulary injected into every container script, so failure
# messages stay consistent and live in one place.
PRELUDE='
assert_fail() { echo "ASSERT: $*"; exit 1; }
need_cmd()  { command -v "$1" >/dev/null || assert_fail "missing command: $1"; }
need_link() { [ -L "$HOME/$1" ] || assert_fail "not a symlink: ~/$1"
              [ -e "$HOME/$1" ] || assert_fail "dangling: ~/$1"; }
no_path()   { [ -e "$1" ] && assert_fail "should not exist: $1"; :; }
'


base_for() { [ "$1" = ubuntu ] && echo "ubuntu:22.04" || echo "debian:12"; }
img_for()  { echo "dotfiles-test-$1"; }

build() {
    local os=$1 img base
    img=$(img_for "$os"); base=$(base_for "$os")
    step "building $img from $base"
    # -q already suppresses build output.
    docker build -q --build-arg BASE_IMAGE="$base" -t "$img" . \
        && ok "build $os" || fail "build $os"
}

# run <os> <script> -- fails the suite if the container exits non-zero
run() {
    local os=$1 name=$2 script=$3
    step "$name ($os)"
    if docker run --rm "$(img_for "$os")" bash -eo pipefail -c "$PRELUDE$script"; then
        ok "$name ($os)"
    else
        fail "$name ($os)"
    fi
}

test_syntax() {
    run "$1" "syntax" '
        for f in setup.sh clean.sh lib.sh; do
            sh -n "$f" || assert_fail "POSIX syntax error in $f"
        done
        echo "all scripts parse under POSIX sh"'
}

test_minimal() {
    run "$1" "minimal install + link" '
        sh setup.sh --minimal --yes
        # stow must NOT be needed
        if command -v stow >/dev/null; then assert_fail "unexpected: stow present"; fi
        for c in git curl tmux vim; do need_cmd "$c"; done
        for l in .zshrc .bashrc .aliases .gitconfig .gitignore_global .tmux.conf .vimrc; do
            need_link "$l"
        done
        # minimal must get the plugin-free vimrc
        grep -q "no plugins, no network calls" "$HOME/.vimrc" || assert_fail "wrong .vimrc for minimal"
        no_path "$HOME/.config/nvim"
        [ -f "$HOME/.gitconfig.local" ] || assert_fail "missing ~/.gitconfig.local"
        echo "minimal OK"
    '
}

test_shell_clean() {
    run "$1" "shells start clean" '
        sh setup.sh --minimal --yes >/dev/null 2>&1
        out=$(bash -ic "true" 2>&1); if [ -n "$out" ]; then echo "bash noise: $out"; exit 1; fi
        git check-ignore -v .DS_Store >/dev/null || { echo "excludesfile not resolving"; exit 1; }
        git -c credential.helper= ls-remote . >/dev/null 2>&1 || true
        err=$(git status 2>&1 >/dev/null); if echo "$err" | grep -qi osxkeychain; then
            echo "osxkeychain leaked onto linux"; exit 1; fi
        echo "shells clean, git config portable"
    '
}

test_full() {
    run "$1" "full install" '
        sh setup.sh --full --yes
        for c in nvim git node rg tmux zsh; do need_cmd "$c"; done
        need_link .config/nvim
        nvim --version | head -1
        echo "full OK"
    '
}

test_nvim() {
    run "$1" "neovim config loads" '
        sh setup.sh --full --yes >/dev/null
        nvim --headless -c "lua print(\"CONFIG LOADED\")" -c "qa" 2>&1 | tee /tmp/o
        grep -q "CONFIG LOADED" /tmp/o || assert_fail "config did not load"
        grep -qi "^E[0-9]\+:" /tmp/o && assert_fail "vim error during load"
        echo "neovim OK"
    '
}

test_unlink() {
    run "$1" "clean.sh unlink round-trip" '
        echo "ORIGINAL" > "$HOME/.zshrc"
        sh setup.sh --minimal --yes >/dev/null
        need_link .zshrc
        yes | sh clean.sh unlink >/dev/null 2>&1 || true
        [ -L "$HOME/.zshrc" ] && assert_fail "symlink survived unlink"
        grep -q ORIGINAL "$HOME/.zshrc" || assert_fail "backup not restored"
        echo "round-trip OK"
    '
}

case "${2:-both}" in both) OSES="debian ubuntu" ;; *) OSES=$2 ;; esac
each()  { for os in $OSES; do "$1" "$os"; done; }
suite() { for t in test_syntax test_minimal test_shell_clean test_unlink; do each "$t"; done; }

case "${1:-test}" in
    build)     each build ;;
    test)      suite ;;
    test-full) each test_full ;;
    test-nvim) each test_nvim ;;
    shell)     docker run --rm -it "$(img_for "${2:-debian}")" bash ;;
    cleanup)   docker rmi -f dotfiles-test-debian dotfiles-test-ubuntu 2>/dev/null; echo "images removed" ;;
    all)       each build; suite ;;
    *) sed -n '2,4p' "$0"; exit 2 ;;
esac

if [ "$FAILED" -ne 0 ]; then echo "${C_RED}Some tests failed.${C_RESET}"; exit 1; fi
echo "${C_GRN}All tests passed.${C_RESET}"
