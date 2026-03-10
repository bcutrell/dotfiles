# Encoding
export LANG=en_US.UTF-8
export LC_ALL=en_US.UTF-8

# User configuration
export EDITOR="nvim"
export SHELL="zsh"

# Aliases
if [ -f ~/.aliases ]; then
	. ~/.aliases
fi

# Ubuntu bat compatibility
if command -v batcat >/dev/null 2>&1 && ! command -v bat >/dev/null 2>&1; then
    alias bat="batcat"
fi

#
# Ruby
#
# uncomment to use rbenv
# export PATH="${HOME}/.rbenv/bin:${PATH}" # Needed for Linux/WSL
# type -a rbenv > /dev/null && eval "$(rbenv init -)"

#
# Go
#
# uncomment to use go
# export GOPATH=$(go env GOPATH)
# export PATH=$PATH:$GOPATH/bin

#
# Rust
#
# uncomment to use rust
# export PATH="$HOME/.cargo/bin:$PATH"

#
# Python
#
# uncomment to use ipdb
# export PYTHONBREAKPOINT=ipdb.set_trace

# rye
# uncomment to use rye
source "$HOME/.rye/env"

# PATH additions
export PATH="$HOME/.local/bin:$PATH"
export PATH="$PATH:$HOME/go/bin"
export BUN_INSTALL="$HOME/Library/Application Support/reflex/bun"
export PATH="$BUN_INSTALL/bin:$PATH"

# startship
# uncomment to use starship 
eval "$(starship init zsh)"

fpath+=~/.zfunc; autoload -Uz compinit; compinit

zstyle ':completion:*' menu select

# History
HISTFILE=~/.zsh_history
HISTSIZE=100000
SAVEHIST=100000
setopt HIST_IGNORE_ALL_DUPS
setopt HIST_IGNORE_SPACE
setopt SHARE_HISTORY
setopt EXTENDED_HISTORY
setopt HIST_FIND_NO_DUPS
setopt HIST_REDUCE_BLANKS

# fzf history search - selects command onto prompt without running
h() {
  print -z $(fc -rl 1 | awk '{$1=""; print substr($0,2)}' | fzf)
}

# FZF shell integration (Ctrl+R history, Ctrl+T file picker, Alt+C cd)
if command -v fzf >/dev/null 2>&1; then
  eval "$(fzf --zsh)"
  export FZF_DEFAULT_COMMAND='rg --files --hidden --glob "!.git"'
  export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
fi
