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

" Shared clipboard.
" Inside tmux, yanks go to the tmux paste buffer, which every pane, window
" and session on that tmux server shares (Neovim reads and writes the same
" buffer). `load-buffer -w` also forwards the copy via OSC 52 -- through ssh
" if need be -- to the terminal you are sitting at (tmux: set-clipboard on).
" Without tmux, write the OSC 52 sequence ourselves; Vim has no built-in
" support. Pasting *from* the Mac is the terminal's own paste (Cmd+V), which
" arrives as keystrokes; OSC 52 reads are refused by most terminals.
if exists('##TextYankPost') && !has('gui_running')
  function! s:ShareYank(text) abort
    if !empty($TMUX)
      call system('tmux load-buffer -w -', a:text)
      return
    endif
    " Terminals cap the sequence length; skip absurd yanks.
    if strlen(a:text) > 74994
      return
    endif
    let l:b64 = substitute(system('base64 | tr -d "\n"', a:text), '\n', '', 'g')
    silent! call writefile(["\e]52;c;" . l:b64 . "\a"], '/dev/tty', 'b')
  endfunction

  augroup ShareYank
    autocmd!
    autocmd TextYankPost *
          \ if v:event.operator ==# 'y' && v:event.regname ==# '' |
          \   call s:ShareYank(join(v:event.regcontents, "\n")) |
          \ endif
  augroup END

  " ,p / ,P paste the shared tmux buffer -- whatever tmux copy mode, Neovim
  " or another vim last copied. A trailing newline makes the put linewise.
  if !empty($TMUX)
    function! s:PasteTmux(how) abort
      let @" = system('tmux save-buffer - 2>/dev/null')
      execute 'normal! ' . a:how
    endfunction
    nnoremap <silent> ,p :call <SID>PasteTmux('p')<CR>
    nnoremap <silent> ,P :call <SID>PasteTmux('P')<CR>
  endif
endif
