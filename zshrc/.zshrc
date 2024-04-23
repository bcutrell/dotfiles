#
# oh-my-zsh
#
export ZSH=$HOME/.oh-my-zsh # Path to  oh-my-zsh installation

# https://github.com/robbyrussell/oh-my-zsh/wiki/themes
ZSH_THEME="robbyrussell"

plugins=(
    git
    gitfast
    last-working-dir
    common-aliases
    history-substring-search
)

source $ZSH/oh-my-zsh.sh # Load oh-my-zsh
unalias rm # No interactive rm by default (brought by plugins/common-aliases)

# Encoding
export LANG=en_US.UTF-8
export LC_ALL=en_US.UTF-8

# User configuration
export EDITOR='nvim'
export SHELL="zsh"

#
# Ruby
#
export PATH="${HOME}/.rbenv/bin:${PATH}" # Needed for Linux/WSL
type -a rbenv > /dev/null && eval "$(rbenv init -)"

#
# Go
#
export GOPATH=$(go env GOPATH)
export PATH=$PATH:$GOPATH/bin

#
# Rust
#
export PATH="$HOME/.cargo/bin:$PATH"

#
# Python
#
export PYTHONBREAKPOINT=ipdb.set_trace

# rye
source "$HOME/.rye/env"

#
# Alias
#
alias restart_shell="exec $SHELL"
alias ls='ls --color=auto'
alias c="clear"
alias search="rg -S"

# git
alias gs="git status"
alias gco="git checkout"
alias ggn="git grep -n"
alias gd="git diff"
alias gb="git branch"
alias gl="git log"
alias gs="git status"

