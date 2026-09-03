# Encoding. LANG only -- setting LC_ALL overrides every category and breaks on
# minimal Linux images where en_US.UTF-8 has not been generated.
export LANG=en_US.UTF-8

if (( $+commands[nvim] )); then export EDITOR=nvim; else export EDITOR=vim; fi

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
# macOS-only bun install; guarded so it does not prepend a missing dir on Linux
if [ -d "$HOME/Library/Application Support/reflex/bun/bin" ]; then
    export PATH="$HOME/Library/Application Support/reflex/bun/bin:$PATH"
fi

# Completions. Rebuild the dump at most once a day; a bare `compinit` stats
# every file in $fpath on every shell start.
fpath+=~/.zfunc
autoload -Uz compinit
# Note: (#q...) needs EXTENDED_GLOB and [[ ]] does not glob at all, so use an
# array assignment -- that globs unconditionally. mh-24 = modified <24h ago.
_zdump=${ZDOTDIR:-$HOME}/.zcompdump
_zfresh=( $_zdump(N.mh-24) )
if (( $#_zfresh )); then
    compinit -C -d $_zdump    # fresh dump: skip the security scan of $fpath
else
    compinit -d $_zdump       # missing or stale: full rebuild
fi
# Compile the dump to wordcode; `source` prefers the .zwc automatically.
[[ $_zdump.zwc -nt $_zdump ]] || zcompile $_zdump 2>/dev/null
unset _zdump _zfresh
zstyle ':completion:*' menu select

# Cached shell-integration scripts. `starship init` / `fzf --zsh` each cost a
# fork+exec of a large binary; sourcing a cache file that is regenerated only
# when the binary changes is markedly faster on a weak box.
_zcache=$HOME/.cache/zsh
[[ -d $_zcache ]] || mkdir -p $_zcache

# Prompt. starship is only installed by the full tier, so fall back to a
# native prompt rather than erroring on every shell start.
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

# History
HISTFILE=~/.zsh_history
HISTSIZE=100000
SAVEHIST=100000
setopt HIST_IGNORE_ALL_DUPS HIST_IGNORE_SPACE SHARE_HISTORY
setopt EXTENDED_HISTORY HIST_FIND_NO_DUPS HIST_REDUCE_BLANKS

# fzf: Ctrl+R history, Ctrl+T files, Alt+C cd
if (( $+commands[fzf] )); then
    [[ $_zcache/fzf.zsh -nt $commands[fzf] ]] || fzf --zsh > $_zcache/fzf.zsh
    source $_zcache/fzf.zsh
    if (( $+commands[rg] )); then
        export FZF_DEFAULT_COMMAND='rg --files --hidden --glob "!.git"'
        export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
    fi
fi

unset _zcache
