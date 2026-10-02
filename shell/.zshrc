[ -f ~/.aliases ] && . ~/.aliases

# Completions: rebuild the dump at most once a day.
fpath+=~/.zfunc
autoload -Uz compinit
_zdump=${ZDOTDIR:-$HOME}/.zcompdump
_zfresh=( $_zdump(N.mh-24) )
if (( $#_zfresh )); then compinit -C -d $_zdump; else compinit -d $_zdump; fi
[[ $_zdump.zwc -nt $_zdump ]] || zcompile $_zdump 2>/dev/null
unset _zdump _zfresh
zstyle ':completion:*' menu select

HISTFILE=~/.zsh_history
HISTSIZE=100000
SAVEHIST=100000
setopt HIST_IGNORE_ALL_DUPS HIST_IGNORE_SPACE SHARE_HISTORY
setopt EXTENDED_HISTORY HIST_FIND_NO_DUPS HIST_REDUCE_BLANKS

# starship/fzf init is cached and regenerated only when the binary changes.
_zcache=$HOME/.cache/zsh
[[ -d $_zcache ]] || mkdir -p $_zcache

if (( $+commands[starship] )); then
    [[ $_zcache/starship.zsh -nt $commands[starship] ]] \
        || starship init zsh --print-full-init > $_zcache/starship.zsh
    source $_zcache/starship.zsh
else
    autoload -Uz vcs_info
    zstyle ':vcs_info:git:*' formats '%b '
    precmd() { vcs_info }
    setopt PROMPT_SUBST
    PROMPT='%F{cyan}%~%f %F{magenta}${vcs_info_msg_0_}%f%# '
fi

if (( $+commands[fzf] )); then
    [[ $_zcache/fzf.zsh -nt $commands[fzf] ]] || fzf --zsh > $_zcache/fzf.zsh
    source $_zcache/fzf.zsh
    # h: pick a history entry onto the prompt without running it.
    h() {
        zmodload -F zsh/parameter p:history 2>/dev/null
        local sel n
        sel=$(fc -rl 1 |
            awk '{ c=$0; sub(/^[ \t]*[0-9]+\**[ \t]+/, "", c); if (!seen[c]++) print }' |
            fzf -n2.. --scheme=history) || return
        n=${${(z)sel}[1]}
        n=${n%%\**}
        [[ $n == <1-> ]] || return
        print -z -- "${history[$n]}"
    }
fi
unset _zcache
