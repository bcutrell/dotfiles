" vim-plug autoinstall
let data_dir = has('nvim') ? stdpath('data') . '/site' : '~/.vim'
if empty(glob(data_dir . '/autoload/plug.vim'))
  silent execute '!curl -fLo '.data_dir.'/autoload/plug.vim --create-dirs  https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim'
  autocmd VimEnter * PlugInstall --sync | source $MYVIMRC
endif

" Begin vim-plug section
call plug#begin('~/.vim/plugged')

" File navigation

Plug 'ctrlpvim/ctrlp.vim'
Plug 'preservim/nerdtree'
Plug 'junegunn/fzf', { 'do': { -> fzf#install() } }
Plug 'junegunn/fzf.vim'

" Programming features
Plug 'tpope/vim-fugitive'           " Git integration
Plug 'preservim/tagbar'             " Code structure viewer
Plug 'dense-analysis/ale'           " Async linting
Plug 'tpope/vim-surround'           " Surround text objects
Plug 'tpope/vim-commentary'         " Easy commenting
Plug 'jiangmiao/auto-pairs'         " Auto pair brackets

" Theme and visuals
Plug 'itchyny/lightline.vim'        " Status line
Plug 'ap/vim-css-color'             " Color preview
Plug 'ghifarit53/tokyonight-vim'


call plug#end()

" General Settings
set nocompatible
filetype plugin indent on
syntax enable
set encoding=utf-8
set fileencoding=utf-8
set hidden
set nobackup
set nowritebackup
set cmdheight=2
set updatetime=300
set shortmess+=c
set signcolumn=yes

" UI Configuration
set number
set relativenumber
set ruler
set cursorline
set showcmd
set noshowmode          " Don't show mode (lightline handles this)
set wildmenu
set wildmode=longest:full,full
set laststatus=2
set scrolloff=8
" set colorcolumn=80
set termguicolors
let g:tokyonight_style = 'night' " Options: 'storm', 'night', 'day'
let g:tokyonight_enable_italic = 1
let g:tokyonight_transparent_background = 0
colorscheme tokyonight

" Indentation
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

" Split Management
set splitbelow
set splitright
nnoremap <C-J> <C-W>j
nnoremap <C-K> <C-W>k
nnoremap <C-L> <C-W>l
nnoremap <C-H> <C-W>h

" Plugin Configuration
" NERDTree
let g:NERDTreeShowHidden=1
let g:NERDTreeMinimalUI=1
nmap ,d :NERDTreeFind<CR>
autocmd BufEnter * if tabpagenr('$') == 1 && winnr('$') == 1 && exists('b:NERDTree') && b:NERDTree.isTabTree() | quit | endif

" CtrlP
let g:ctrlp_match_window = 'order:ttb,max:20'
let g:ctrlp_working_path_mode = 'ra'
let g:ctrlp_user_command = ['.git/', 'git --git-dir=%s/.git ls-files -oc --exclude-standard']
nmap ,t :CtrlP<CR>
nmap ,b :CtrlPBuffer<CR>

" Tagbar
nmap ,m :TagbarToggle<CR>

" FZF
nmap ,f :Files<CR>
nmap ,g :GFiles<CR>
nmap ,r :Rg<CR>

" Lightline
let g:lightline = {
      \ 'colorscheme': 'tokyonight',
      \ 'active': {
      \   'left': [ [ 'mode', 'paste' ],
      \             [ 'gitbranch', 'readonly', 'filename', 'modified' ] ]
      \ },
      \ 'component_function': {
      \   'gitbranch': 'FugitiveHead'
      \ },
      \ }

" ALE
let g:ale_linters = {
\   'python': ['flake8', 'pylint'],
\   'javascript': ['eslint'],
\}
let g:ale_fixers = {
\   '*': ['remove_trailing_lines', 'trim_whitespace'],
\   'python': ['black'],
\   'javascript': ['prettier'],
\}
let g:ale_fix_on_save = 1

" Git commit settings
autocmd Filetype gitcommit setlocal spell textwidth=72

" Disable automatic commenting
augroup auto_comment
  au!
  au FileType * setlocal formatoptions-=c formatoptions-=r formatoptions-=o
augroup END

" Terminal debugging
let g:termdebug_popup = 0
let g:termdebug_wide = 163
packadd termdebug

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
