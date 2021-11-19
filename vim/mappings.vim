nnoremap <Leader>r :!%:p<CR>

noremap <C-h> <C-w>h
noremap <C-j> <C-w>j
noremap <C-k> <C-w>k
noremap <C-l> <C-w>l

nnoremap <Leader>ev :split $HOME/.vim/vimrc<cr>
nnoremap <Leader>sv :source $HOME/.vim/vimrc<cr>

nnoremap <Leader>qo :copen<cr>
nnoremap <Leader>qc :cclose<bar>lclose<cr>
nnoremap <Leader>lo :lopen<cr>
nnoremap <Leader>lc :cclose<bar>lclose<cr>

" Do not change default register content.
nnoremap c "_c
xnoremap c "_c
nnoremap C "_C
xnoremap C "_C

function! s:get_char_at_col(col)
  " To support multi-bytes character.
  return matchstr(getline('.'), '\%' . a:col . 'c.')
endfunction

" Put without changing default register content when in visual selection mode.
function! s:xput() range
  let pre = ''
  let post = ''
  let pos = getcurpos()
  let mode = visualmode()
  if mode == 'v'
    let firstcol = col("'<")
    let lastcol = col("'>")
    if firstcol > 1
      let pre = getline(a:firstline)[:(firstcol - 2)]
    endif
    let post = getline(a:lastline)[(lastcol + len(s:get_char_at_col(lastcol)) - 1):]
  endif

  exe a:firstline . ',' . a:lastline . 'd _'
  " The quoteplus register is synchronized with system clipboard, while the
  " quotestar register is used to save the selection in Linux system.
  let lines = split(getreg('+'), "\<c-j>")
  let lines[0] = pre . lines[0]
  let lines[len(lines) - 1] .= post
  if a:firstline <= 1 && line('$') <= 1
    call setline(1, lines)
  else
    call append(a:firstline - 1, lines)
  endif

  let pos[2] = pos[4]
  call setpos('.', pos)
endfunction

xnoremap <Plug>(visual-put-without-messing-register) :call <SID>xput()<CR>
xmap <silent> p <Plug>(visual-put-without-messing-register)
xmap <silent> P <Plug>(visual-put-without-messing-register)

" In plugin_settings/coc.vim, we remapped <C-]>, so in order to quickly jump
" to the first tag for a source file like C, we do below mapping (because in
" most cases, we donot want a list). Use `:tjump` to select from a list.
nnoremap g<c-]> <c-]>
