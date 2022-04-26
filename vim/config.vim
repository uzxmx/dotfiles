set nocompatible

set encoding=utf-8
set fileencodings-=latin1
set fileencodings+=gb18030,latin1
set autoindent
set cursorline
set mouse=a
set splitbelow
set splitright
set number
set clipboard+=unnamedplus
set backspace=indent,eol,start
set list lcs=tab:\|\ 
set confirm
set cmdheight=2

" This will look in the current directory for tags, and walk up the tree
" towards root until one is found
set tags=./.tags;/,./tags;/

set expandtab
set tabstop=2
set shiftwidth=2
set softtabstop=2
set wrap
set wildmode=longest,list

set ignorecase
set smartcase
set incsearch
set gdefault

" Do not close any fold by using a high number.
set foldlevel=99
set foldlevelstart=99
set foldmethod=indent

" Use the below config to avoid tabstop to be overridden in
" $VIMRUNTIME/ftpplugin/python.vim
let g:python_recommended_style = 0
