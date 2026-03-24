" vim-light: no plugins, no network calls
" For use on low-resource machines

set nocompatible
filetype plugin indent on
syntax enable

" UI
set number
set relativenumber
set ruler
set cursorline
set showcmd
set wildmenu
set wildmode=longest:full,full
set laststatus=2
set scrolloff=8
set signcolumn=yes

" Encoding
set encoding=utf-8
set fileencoding=utf-8

" Editing
set hidden
set nobackup
set nowritebackup
set autoindent
set smartindent
set tabstop=2
set softtabstop=2
set shiftwidth=2
set expandtab
set smarttab

" Search
set ignorecase
set smartcase
set hlsearch
set incsearch

" Splits
set splitbelow
set splitright
nnoremap <C-J> <C-W>j
nnoremap <C-K> <C-W>k
nnoremap <C-L> <C-W>l
nnoremap <C-H> <C-W>h

" History
set undofile
set undodir=~/.vim/undodir
silent! call mkdir(expand('~/.vim/undodir'), 'p')

" Leader
let mapleader = ' '

" Clear search highlight
nnoremap <Esc> :nohlsearch<CR>

" Git commit settings
autocmd FileType gitcommit setlocal spell textwidth=72

" Disable auto-comment continuation
augroup auto_comment
  au!
  au FileType * setlocal formatoptions-=c formatoptions-=r formatoptions-=o
augroup END
