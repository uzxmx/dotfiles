let g:vim_home = expand('<sfile>:p:h:h:h') . '/.vim'
execute 'set runtimepath^=' . g:vim_home . ' runtimepath+=' . g:vim_home . '/after'
let &packpath = &runtimepath
silent! lang en_US.UTF-8
execute 'source ' . g:vim_home . '/vimrc'
