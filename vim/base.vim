" Shared by vim/.vimrc (full) and vim-light/.vimrc (minimal).
set nocompatible
filetype plugin indent on
syntax enable
set encoding=utf-8
set fileencoding=utf-8

set number relativenumber ruler cursorline showcmd
set wildmenu wildmode=longest:full,full
set laststatus=2 scrolloff=8 signcolumn=yes
set hidden nobackup nowritebackup
set autoindent smartindent expandtab smarttab
set tabstop=2 softtabstop=2 shiftwidth=2
set ignorecase smartcase hlsearch incsearch
set splitbelow splitright
set undofile undodir=~/.vim/undodir
silent! call mkdir(expand('~/.vim/undodir'), 'p')

let mapleader = ' '
nnoremap <Esc> :nohlsearch<CR>
nnoremap <C-J> <C-W>j
nnoremap <C-K> <C-W>k
nnoremap <C-L> <C-W>l
nnoremap <C-H> <C-W>h

augroup base
  autocmd!
  autocmd FileType gitcommit setlocal spell textwidth=72
  autocmd FileType * setlocal formatoptions-=c formatoptions-=r formatoptions-=o
augroup END

" Clipboard: yanks go to the tmux buffer (which forwards via OSC 52), or
" straight to the terminal via OSC 52 outside tmux. ,p / ,P paste the tmux buffer.
if exists('##TextYankPost') && !has('gui_running')
  function! s:ShareYank(text) abort
    if !empty($TMUX)
      call system('tmux load-buffer -w -', a:text)
    elseif strlen(a:text) <= 74994
      let l:b64 = substitute(system('base64 | tr -d "\n"', a:text), '\n', '', 'g')
      silent! call writefile(["\e]52;c;" . l:b64 . "\a"], '/dev/tty', 'b')
    endif
  endfunction
  augroup ShareYank
    autocmd!
    autocmd TextYankPost *
          \ if v:event.operator ==# 'y' && v:event.regname ==# '' |
          \   call s:ShareYank(join(v:event.regcontents, "\n")) |
          \ endif
  augroup END
  if !empty($TMUX)
    function! s:PasteTmux(how) abort
      let @" = system('tmux save-buffer - 2>/dev/null')
      execute 'normal! ' . a:how
    endfunction
    nnoremap <silent> ,p :call <SID>PasteTmux('p')<CR>
    nnoremap <silent> ,P :call <SID>PasteTmux('P')<CR>
  endif
endif
