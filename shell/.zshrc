# Encoding
export LANG=en_US.UTF-8
export LC_ALL=en_US.UTF-8

# User configuration
export EDITOR="nvim"
export SHELL="zsh"


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

eval "$(starship init zsh)"

setopt histignoredups

alias history="fc -l $NUMBER"

alias gitapplyplz="git apply --ignore-space-change --ignore-whitespace"

alias findlarge='function _findlarge() { find "${1:-.}" -type f -print0 | xargs -0 du -sh | sort -rh | head -n "${2:-10}"; }; _findlarge'
