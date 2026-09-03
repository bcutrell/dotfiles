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

" Clipboard over SSH via OSC 52.
" Vim has no built-in support, so encode the yank into an escape sequence and
" write it to the terminal. It travels back through ssh -- and through tmux,
" which forwards it when set-clipboard is on -- to the terminal you are sitting
" at, so a yank on a remote box lands on the local clipboard.
" Pasting the other way is the terminal's own paste (Cmd+V), which arrives as
" keystrokes; OSC 52 reads are refused by most terminals, so we do not try.
if exists('##TextYankPost') && !has('gui_running')
  function! s:Osc52(text) abort
    " Terminals and tmux cap the sequence length; skip absurd yanks.
    if strlen(a:text) > 74994
      return
    endif
    let l:b64 = substitute(system('base64 | tr -d "\n"', a:text), '\n', '', 'g')
    silent! call writefile(["\e]52;c;" . l:b64 . "\a"], '/dev/tty', 'b')
  endfunction

  augroup Osc52Yank
    autocmd!
    autocmd TextYankPost *
          \ if v:event.operator ==# 'y' && v:event.regname ==# '' |
          \   call s:Osc52(join(v:event.regcontents, "\n")) |
          \ endif
  augroup END
endif
