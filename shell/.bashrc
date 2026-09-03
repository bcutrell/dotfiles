# Only run for interactive shells.
case $- in *i*) ;; *) return ;; esac

# LANG only -- LC_ALL overrides every category and breaks on minimal images
# where en_US.UTF-8 has not been generated.
export LANG=en_US.UTF-8

command -v nvim >/dev/null 2>&1 && export EDITOR=nvim || export EDITOR=vim

[ -f ~/.aliases ] && . ~/.aliases

# Ubuntu ships bat as batcat
if command -v batcat >/dev/null 2>&1 && ! command -v bat >/dev/null 2>&1; then
    alias bat="batcat"
fi

#
# Language toolchains -- uncomment as needed
#
# export PATH="${HOME}/.rbenv/bin:${PATH}"; eval "$(rbenv init -)"
# export GOPATH=$(go env GOPATH); export PATH=$PATH:$GOPATH/bin
# export PATH="$HOME/.cargo/bin:$PATH"
# export PYTHONBREAKPOINT=ipdb.set_trace

[ -f "$HOME/.rye/env" ] && . "$HOME/.rye/env"

# PATH
export PATH="$HOME/.local/bin:$PATH"
[ -d "$HOME/go/bin" ] && export PATH="$PATH:$HOME/go/bin"

# History
export HISTFILE=~/.bash_history
export HISTSIZE=100000
export HISTFILESIZE=100000
export HISTCONTROL=ignoreboth:erasedups
shopt -s histappend checkwinsize
PROMPT_COMMAND="${PROMPT_COMMAND:+$PROMPT_COMMAND$'\n'}history -a"

# Cached shell-integration scripts. `starship init bash` only prints a line
# that re-execs starship, so the naive eval spawns it twice per shell.
_bcache=$HOME/.cache/bash
[ -d "$_bcache" ] || mkdir -p "$_bcache"

# Prompt. starship if present, otherwise a native prompt with the git branch.
# Stock Debian's .bashrc sets PS1; this file replaces it, so it must set one.
if command -v starship >/dev/null 2>&1; then
    _sb=$(command -v starship)
    [ "$_bcache/starship.bash" -nt "$_sb" ] \
        || starship init bash --print-full-init > "$_bcache/starship.bash"
    . "$_bcache/starship.bash"
else
    # Branch name straight out of .git/HEAD: no forks at all. A $(...) inside
    # PS1 would fork a subshell plus git on every prompt, in or out of a repo.
    # Tradeoff: detached HEAD shows a raw SHA, and linked worktrees/submodules
    # (where .git is a file) show no branch.
    __set_ps1() {
        local d=$PWD b g=
        while [ -n "$d" ]; do
            if [ -f "$d/.git/HEAD" ]; then
                read -r b < "$d/.git/HEAD"
                g=" (${b#ref: refs/heads/})"
                break
            fi
            [ -e "$d/.git" ] && break
            d=${d%/*}
        done
        case "$TERM" in
            xterm-color|*-256color|screen*|tmux*|alacritty|wezterm|xterm-ghostty)
                PS1='\[\033[36m\]\w\[\033[35m\]'$g'\[\033[0m\]\$ ' ;;
            *)
                PS1='\w'$g'\$ ' ;;
        esac
    }
    PROMPT_COMMAND="${PROMPT_COMMAND:+$PROMPT_COMMAND$'\n'}__set_ps1"
fi

# fzf: Ctrl+R history, Ctrl+T files
if command -v fzf >/dev/null 2>&1; then
    _fb=$(command -v fzf)
    [ "$_bcache/fzf.bash" -nt "$_fb" ] || fzf --bash > "$_bcache/fzf.bash" 2>/dev/null
    [ -s "$_bcache/fzf.bash" ] && . "$_bcache/fzf.bash"
    if command -v rg >/dev/null 2>&1; then
        export FZF_DEFAULT_COMMAND='rg --files --hidden --glob "!.git"'
        export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
    fi
fi
