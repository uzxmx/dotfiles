if has('python3') " This will force python3 to be used
  silent echomsg 'Use python3'
endif

set nocompatible

let mapleader = "\<Space>"
let maplocalleader = "\<Space>"

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
set tags=./.tags;/,./tags;/ " This will look in the current directory for tags, and walk up the tree towards root until one is found

set expandtab
set tabstop=2
set shiftwidth=2
set softtabstop=2
set wrap
set wildmode=longest,list

set background=dark
" solarized scheme is loaded by vim-plug, but the post hook for loadig plugin
" doesn't work, so here we just ignore the error.
silent! colorscheme solarized

set ignorecase
set smartcase
set incsearch
set gdefault

set foldlevelstart=99
set foldmethod=indent

" Use the below config to avoid tabstop to be overridden in
" $VIMRUNTIME/ftpplugin/python.vim
" TODO
let g:python_recommended_style = 0
