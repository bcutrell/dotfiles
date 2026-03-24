# Encoding
export LANG=en_US.UTF-8
export LC_ALL=en_US.UTF-8

# User configuration
export EDITOR='vim'
export SHELL="bash"

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

# History
export HISTFILE=~/.bash_history
export HISTSIZE=100000
export HISTFILESIZE=100000
export HISTCONTROL=ignoreboth:erasedups
shopt -s histappend
PROMPT_COMMAND="${PROMPT_COMMAND:+$PROMPT_COMMAND$'\n'}history -a"

# PATH additions
export PATH="$HOME/.local/bin:$PATH"
export PATH="$PATH:$HOME/go/bin"
