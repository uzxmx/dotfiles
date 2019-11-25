" You will have bad experience for diagnostic messages when it's default 4000.
set updatetime=300

function! s:check_back_space() abort
  let col = col('.') - 1
  return !col || getline('.')[col - 1]  =~# '\s'
endfunction

" Use tab for trigger completion with characters ahead and navigate.
" Use command ':verbose imap <tab>' to make sure tab is not mapped by other plugin.
inoremap <silent><expr> <TAB>
     \ pumvisible() ? "\<C-n>" :
     \ <SID>check_back_space() ? "\<TAB>" :
     \ coc#refresh()
inoremap <expr><S-TAB> pumvisible() ? "\<C-p>" : "\<C-h>"

noremap <Leader>cd <Plug>(coc-definition)
noremap <Leader>ct <Plug>(coc-type-definition)
noremap <Leader>ci <Plug>(coc-implementation)
noremap <Leader>cr <Plug>(coc-references)
