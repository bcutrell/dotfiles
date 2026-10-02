" vim-light: no plugins, no network calls
execute 'source' fnameescape(fnamemodify(resolve(expand('<sfile>:p')), ':h') . '/../vim/base.vim')

set background=dark
silent! colorscheme habamax
