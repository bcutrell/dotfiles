case $- in *i*) ;; *) return ;; esac

[ -f ~/.aliases ] && . ~/.aliases

export HISTFILE=~/.bash_history
export HISTSIZE=100000
export HISTFILESIZE=100000
export HISTCONTROL=ignoreboth:erasedups
shopt -s histappend checkwinsize
PROMPT_COMMAND="${PROMPT_COMMAND:+$PROMPT_COMMAND$'\n'}history -a"

# starship/fzf init is cached and regenerated only when the binary changes.
_bcache=$HOME/.cache/bash
[ -d "$_bcache" ] || mkdir -p "$_bcache"

if command -v starship >/dev/null 2>&1; then
    _sb=$(command -v starship)
    [ "$_bcache/starship.bash" -nt "$_sb" ] \
        || starship init bash --print-full-init > "$_bcache/starship.bash"
    . "$_bcache/starship.bash"
else
    # Branch name read from .git/HEAD: no forks per prompt.
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
            *)  PS1='\w'$g'\$ ' ;;
        esac
    }
    PROMPT_COMMAND="${PROMPT_COMMAND:+$PROMPT_COMMAND$'\n'}__set_ps1"
fi

if command -v fzf >/dev/null 2>&1; then
    _fb=$(command -v fzf)
    [ "$_bcache/fzf.bash" -nt "$_fb" ] || fzf --bash > "$_bcache/fzf.bash" 2>/dev/null
    [ -s "$_bcache/fzf.bash" ] && . "$_bcache/fzf.bash"
    # h: pick a history entry; it is pushed onto history, press Up to recall.
    h() {
        local cmd
        cmd=$(__fzf_history__) || return
        [ -n "$cmd" ] || return
        history -s "$cmd"
        printf '%s\n' "$cmd"
    }
fi
unset _bcache _sb _fb
