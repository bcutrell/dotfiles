execute 'source' fnameescape(fnamemodify(resolve(expand('<sfile>:p')), ':h') . '/base.vim')

let data_dir = has('nvim') ? stdpath('data') . '/site' : '~/.vim'
if empty(glob(data_dir . '/autoload/plug.vim'))
  silent execute '!curl -fLo '.data_dir.'/autoload/plug.vim --create-dirs  https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim'
  autocmd VimEnter * PlugInstall --sync | source $MYVIMRC
endif

call plug#begin('~/.vim/plugged')
Plug 'ctrlpvim/ctrlp.vim'
Plug 'preservim/nerdtree'
Plug 'junegunn/fzf', { 'do': { -> fzf#install() } }
Plug 'junegunn/fzf.vim'
Plug 'tpope/vim-fugitive'
Plug 'preservim/tagbar'
Plug 'dense-analysis/ale'
Plug 'tpope/vim-surround'
Plug 'tpope/vim-commentary'
Plug 'jiangmiao/auto-pairs'
Plug 'itchyny/lightline.vim'
Plug 'ap/vim-css-color'
Plug 'ghifarit53/tokyonight-vim'
call plug#end()

set cmdheight=2 updatetime=300 shortmess+=c noshowmode
set termguicolors
let g:tokyonight_style = 'night'
let g:tokyonight_enable_italic = 1
silent! colorscheme tokyonight

let g:NERDTreeShowHidden = 1
let g:NERDTreeMinimalUI = 1
nmap ,d :NERDTreeFind<CR>
autocmd BufEnter * if tabpagenr('$') == 1 && winnr('$') == 1 && exists('b:NERDTree') && b:NERDTree.isTabTree() | quit | endif

let g:ctrlp_match_window = 'order:ttb,max:20'
let g:ctrlp_working_path_mode = 'ra'
let g:ctrlp_user_command = ['.git/', 'git --git-dir=%s/.git ls-files -oc --exclude-standard']
nmap ,t :CtrlP<CR>
nmap ,b :CtrlPBuffer<CR>
nmap ,m :TagbarToggle<CR>
nmap ,f :Files<CR>
nmap ,g :GFiles<CR>
nmap ,r :Rg<CR>

let g:lightline = {
      \ 'colorscheme': 'tokyonight',
      \ 'active': { 'left': [ [ 'mode', 'paste' ], [ 'gitbranch', 'readonly', 'filename', 'modified' ] ] },
      \ 'component_function': { 'gitbranch': 'FugitiveHead' },
      \ }

let g:ale_linters = { 'python': ['flake8', 'pylint'], 'javascript': ['eslint'] }
let g:ale_fixers = {
      \ '*': ['remove_trailing_lines', 'trim_whitespace'],
      \ 'python': ['black'],
      \ 'javascript': ['prettier'],
      \ }
let g:ale_fix_on_save = 1

let g:termdebug_popup = 0
let g:termdebug_wide = 163
packadd termdebug
