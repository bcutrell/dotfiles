execute pathogen#infect()
filetype plugin indent on

set ruler
set cursorline
set number
set tabstop=2 shiftwidth=2 expandtab

nnoremap <C-J> <C-W>j
nnoremap <C-K> <C-W>k
nnoremap <C-L> <C-W>l
nnoremap <C-H> <C-W>h

syntax enable
" colors managed by iterm
" set background=light
" let g:solarized_termcolors=256
" set background=dark
" colorscheme solarized
" let g:solarized_termcolors=16
" let g:solarized_visibility = "high"
" let g:solarized_contrast = "high"
" let g:solarized_termtrans=1

autocmd Filetype gitcommit setlocal spell textwidth=72

""nmap ,f :FufFileWithCurrentBufferDir<CR>
""nmap ,s :FufFile<CR>
""nmap ,b :FufBuffer<CR>
""nmap ,t :FufTaggedFile<CR>

" plugin settings
nmap ,t :CtrlP<CR>
nmap ,b :CtrlPBuffer<CR>
nmap ,m :TagbarToggle<CR>
nmap ,d :NERDTreeFind<CR>

let g:ctrlp_match_window = 'order:ttb,max:20'

augroup auto_comment
  au!
  au FileType * setlocal formatoptions-=c formatoptions-=r formatoptions-=o
augroup END

let g:termdebug_popup = 0
let g:termdebug_wide = 163

packadd termdebug
