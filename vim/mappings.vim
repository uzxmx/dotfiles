nnoremap <Leader>r :!%:p<CR>
nnoremap <Leader><Space> :nohlsearch<cr>

" Search visual selected text
vnoremap / y/<c-r>"<cr>

" Keep search matches in the middle of the window.
nnoremap n nzzzv
nnoremap N Nzzzv
" }}}

noremap <C-h> <C-w>h
noremap <C-j> <C-w>j
noremap <C-k> <C-w>k
noremap <C-l> <C-w>l

nnoremap <Leader>ev :split $HOME/.vim/vimrc<cr>
nnoremap <Leader>sv :source $HOME/.vim/vimrc<cr>
" May conflict with glog quick-fix window
" nnoremap <cr> o

nnoremap <leader>co :copen<cr>
nnoremap <leader>cc :cclose<bar>lclose<cr>
