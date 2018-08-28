" Searching ------------------------------------------------------ {{{
" remap # to only highlight cursor word
" also override the mapping from henrik/vim-indexed-search
nnoremap <silent> # :<C-u> set hlsearch<cr>:let @/ = expand('<cword>')<cr>:ShowSearchIndex<cr>
" }}}
