" .vimrc
" Author: Mingxiang Xue <327110424@163.com>
" Source: http://...

" Preamble -------------------------------------------------------------------- {{{
filetype plugin indent on
set nocompatible
" }}}

" Basic options --------------------------------------------------------------- {{{
set encoding=utf-8
set autoindent
set cursorline
set mouse=a
set splitbelow
set splitright
set number
set relativenumber
set textwidth=80
set clipboard^=unnamed
set clipboard^=unnamedplus
set backspace=indent,eol,start

set tags=./.tags;/,./tags;/ " This will look in the current directory for tags, and walk up the tree towards root until one is found
" vim-autotag related settings
let g:autotagTagsFile=".tags"

" Save when losing focus
au FocusLost * :wa
" }}}

" Tabs, spaces, wrapping {{{
set expandtab
set tabstop=2
set shiftwidth=2
set softtabstop=2
set wrap
" }}}

" Wildmenu completion {{{
set wildmode=longest,list
" }}}

" Backups {{{
" set undodir=~/.vim/tmp/undo//     " undo files
" set backupdir=~/.vim/tmp/backup// " backups
" set directory=~/.vim/tmp/swap//   " swap files
" set backup                        " enable backups
" }}}

" Leader {{{
let mapleader = ","
let maplocalleader = "\\"
" }}}

" Color scheme {{{
" syntax on
" let g:airline_theme = 'tender'
" colorscheme tender
" hi Visual guifg=NONE ctermfg=NONE guibg=#666666 ctermbg=245 gui=NONE cterm=NONE
" hi VisualNOS guifg=NONE ctermfg=NONE guibg=#666666 ctermbg=245 gui=NONE cterm=NONE

syntax enable
set background=dark
colorscheme solarized
" }}}

" Status line ----------------------------------------------------------------- {{{
" will hide status line
" set laststatus=0
" }}}

" Searching and movement ------------------------------------------------------ {{{
set ignorecase
set smartcase
set incsearch
" set showmatch
set hlsearch " Use :nohlsearch to clear highlight after searching
set gdefault

" remap # to only highlight cursor word
nnoremap # :<C-u> set hlsearch<cr>:let @/ = expand('<cword>')<cr>

" Keep search matches in the middle of the window.
nnoremap n nzzzv
nnoremap N Nzzzv

" Easier to type, and I never use the default behavior.
noremap H ^
noremap L $
" }}}

" Directional Keys {{{
" Easy buffer navigation
noremap <C-h>  <C-w>h
noremap <C-j>  <C-w>j
noremap <C-k>  <C-w>k
noremap <C-l>  <C-w>l
noremap <leader>v <C-w>v
" }}}

" Folding --------------------------------------------------------------------- {{{
set foldlevelstart=99
set foldmethod=indent

" Space to toggle folds.
nnoremap <Space> za
vnoremap <Space> za
" }}}

" Various filetype-specific stuff --------------------------------------------- {{{
" Javascript {{{
augroup ft_javascript
    au!

    au FileType javascript setlocal foldmethod=marker
    au FileType javascript setlocal foldmarker={,}
    " au FileType javascript setl foldmethod=indent
augroup END
" }}}

" Markdown {{{
augroup ft_markdown
    au!

    au BufNewFile,BufRead *.m*down setlocal filetype=markdown

    " Use <localleader>1/2/3 to add headings.
    au Filetype markdown nnoremap <buffer> <localleader>1 yypVr=
    au Filetype markdown nnoremap <buffer> <localleader>2 yypVr-
    au Filetype markdown nnoremap <buffer> <localleader>3 I### <ESC>
augroup END
" }}}

" QuickFix {{{
augroup ft_quickfix
    au!
    au Filetype qf setlocal colorcolumn=0 nolist nocursorline wrap
augroup END
" }}}

" Ruby {{{
augroup ft_ruby
    au!
    " This will slow the vim
    " au Filetype ruby setlocal foldmethod=syntax

    " For ruby file, if not set re to 1, the ruby syntax will be slow
    au FileType ruby setlocal re=1 
augroup END
" }}}

" Vim {{{
augroup ft_vim
    au!

    au FileType vim setlocal foldmethod=marker
augroup END
" }}}
" }}}

" Quick editing --------------------------------------------------------------- {{{
nnoremap <leader>ev :vsplit $MYVIMRC<cr>
nnoremap <leader>sv :source $MYVIMRC<cr>
" }}}

" NERDTree specific stuff --------------------------- {{{
let NERDTreeMinimalUI = 1
" au VimEnter * NERDTree
" nnoremap <silent> <C-\> :NERDTreeFind<CR>
nnoremap <silent> <C-n>n :NERDTree<CR>
nnoremap <silent> <C-n><C-n> :NERDTree<CR>
nnoremap <silent> <C-n>c :NERDTreeClose<CR>
nnoremap <silent> <C-n>f :NERDTreeFind<CR>
nnoremap <silent> <C-n><C-f> :NERDTreeFind<CR>
nnoremap <silent> <C-n>t :NERDTreeToggle<CR>
nnoremap <silent> <C-n><C-t> :NERDTreeToggle<CR>
nnoremap <silent> <C-n>r :NERDTreeCWD<CR>
nnoremap <silent> <C-n><C-r> :NERDTreeCWD<CR>
" }}}

" NERDCommenter specific stuff {{{
let NERDSpaceDelims = 1
" Python will add two spaces, use this to fix.
let NERDCustomDelimiters = {'python': {'left': '#'}}
" }}}

" Text objects ---------------------------------------------------------------- {{{
" Next and Last {{{
" Motion for "next/last object". For example, "din(" would go to the next "()" pair
" and delete its contents.
onoremap an :<c-u>call <SID>NextTextObject('a', 'f')<cr>
xnoremap an :<c-u>call <SID>NextTextObject('a', 'f')<cr>
onoremap in :<c-u>call <SID>NextTextObject('i', 'f')<cr>
xnoremap in :<c-u>call <SID>NextTextObject('i', 'f')<cr>

onoremap al :<c-u>call <SID>NextTextObject('a', 'F')<cr>
xnoremap al :<c-u>call <SID>NextTextObject('a', 'F')<cr>
onoremap il :<c-u>call <SID>NextTextObject('i', 'F')<cr>
xnoremap il :<c-u>call <SID>NextTextObject('i', 'F')<cr>

function! s:NextTextObject(motion, dir)
  let c = nr2char(getchar())

  if c ==# "b"
      let c = "("
  elseif c ==# "B"
      let c = "{"
  elseif c ==# "d"
      let c = "["
  endif

  exe "normal! ".a:dir.c."v".a:motion.c
endfunction
" }}}
" }}}

" Tabularize {{{
nnoremap <Leader>a= :Tabularize /=<CR>
vnoremap <Leader>a= :Tabularize /=<CR>
nnoremap <Leader>a: :Tabularize /:\zs<CR>
vnoremap <Leader>a: :Tabularize /:\zs<CR>
" }}}

" Use Ag rather than Ack or grep {{{
let g:ackprg = 'ag --nogroup --nocolor --column'
" }}}

" vim-rspec and tslime.vim {{{
let g:rspec_command = 'call Send_to_Tmux("rspec {spec}\n")'
map <Leader>t :call RunCurrentSpecFile()<CR>
map <Leader>s :call RunNearestSpec()<CR>
map <Leader>l :call RunLastSpec()<CR>
map <Leader>a :call RunAllSpecs()<CR>
" }}}

" Misc {{{
" Use the below config to avoid tabstop to be overridden in
" $VIMRUNTIME/ftpplugin/python.vim
let g:python_recommended_style = 0

inoremap <C-d> <Del>

" Open a new tab using the current buffer
" map <C-\> :tab split<CR>:exec("tag ".expand("<cword>"))<CR>
" map <A-]> :vsp <CR>:exec("tag ".expand("<cword>"))<CR>

" If you want :UltiSnipsEdit to split your window.
let g:UltiSnipsEditSplit="vertical"

let g:deoplete#enable_at_startup = 1

" switch the line between the current line and the below line
nnoremap - ddp
" switch the line between the current line and the above line
nnoremap _ ddkP

nnoremap <leader>" viw<esc>a"<esc>bi"<esc>lel
nnoremap <leader>' viw<esc>a'<esc>bi'<esc>lel
nnoremap <leader>\| viw<esc>a\|<esc>bi\|<esc>lel
nnoremap <leader>` viw<esc>a`<esc>bi`<esc>lel
" }}}

" Avoid mistake {{{
command! WQ wq
command! Wq wq
command! W w
command! Q q
" }}}
