" Ref: https://github.com/christoomey/vim-tmux-navigator/issues/205
let g:NERDTreeMapJumpPrevSibling="<m-k>"
let g:NERDTreeMapJumpNextSibling="<m-j>"

let NERDTreeMinimalUI = 1

nnoremap <silent> <C-n>n :NERDTree<CR>
nnoremap <silent> <C-n><C-n> :NERDTree<CR>
nnoremap <silent> <C-n>c :NERDTreeClose<CR>
nnoremap <silent> <C-n>f :NERDTreeFind<CR>
nnoremap <silent> <C-n><C-f> :NERDTreeFind<CR>
nnoremap <silent> <C-n>t :NERDTreeToggle<CR>
nnoremap <silent> <C-n><C-t> :NERDTreeToggle<CR>
