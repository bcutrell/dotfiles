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
