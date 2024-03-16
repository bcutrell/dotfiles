#
# oh-my-zsh
#
export ZSH=$HOME/.oh-my-zsh # Path to  oh-my-zsh installation

# https://github.com/robbyrussell/oh-my-zsh/wiki/themes
ZSH_THEME="robbyrussell"

# plugins
plugins=(
    git
    gitfast
    last-working-dir
    common-aliases
    zsh-syntax-highlighting
    history-substring-search
    poetry
)

# Load oh-my-zsh
source $ZSH/oh-my-zsh.sh
unalias rm # No interactive rm by default (brought by plugins/common-aliases)
unalias lt # we need `lt` for https://github.com/localtunnel/localtunnel

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
export PATH="$HOME/.cargo/bin:$PATH"

#
# Python
#
export PYENV_VIRTUALENV_DISABLE_PROMPT=1
export PYENV_ROOT="$HOME/.pyenv"
export PYTHONBREAKPOINT=ipdb.set_trace
[[ -d $PYENV_ROOT/bin ]] && export PATH="$PYENV_ROOT/bin:$PATH"
type -a pyenv > /dev/null && eval "$(pyenv init -)" && eval "$(pyenv virtualenv-init - 2> /dev/null)" && RPROMPT+='[🐍 $(pyenv version-name)]'
eval "$(pyenv init -)"

#
# Alias
#
alias restart_shell="exec $SHELL"
alias ls='ls --color=auto'
alias c="clear"
