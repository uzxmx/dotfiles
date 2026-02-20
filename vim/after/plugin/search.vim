" This script file should be loaded after henrik/vim-indexed-search.

highlight CurSearch ctermbg=red ctermfg=0 guibg=#cb4b16 guifg=#303030

"highlight CurrentSearch ctermbg=red ctermfg=0 guibg=#cb4b16 guifg=#303030

function s:clear_current_search()
  if exists("w:current_search_match_id")
    silent! call matchdelete(w:current_search_match_id)
    unlet w:current_search_match_id
  endif
endfunction

function s:highlight_current_search()
  "call s:clear_current_search()
  "
  "let pos = getpos('.')
  "" Must be executed separately. The problem is when cursor is at the last
  "" character of a file, `norm! wb` won't go to the beginning of word.
  "norm! w
  "norm! b
  "let pattern = '\m\%'.line('.').'l\%'.col('.').'c'
  "     \ . '\%('.(!&magic?'\M':'').@/.'\m\)'
  "call setpos('.', pos)
  "if &ignorecase
  "  let pattern .= '\c'
  "endif
  "let w:current_search_match_id = matchadd("CurrentSearch", pattern, 2)
endfunction

nnoremap <silent> # :<C-u>set hlsearch<cr>:let @/ = '\<'.expand('<cword>').'\>'<cr>:call <SID>highlight_current_search()<cr>:ShowSearchIndex<cr>
nnoremap <silent> g# :<C-u>set hlsearch<cr>:let @/ = expand('<cword>')<cr>:call <SID>highlight_current_search()<cr>:ShowSearchIndex<cr>

" Keep search matches in the middle of the window.
" nnoremap n nzzzv
" nnoremap N Nzzzv
nnoremap <silent> n n:call <SID>highlight_current_search()<cr>:ShowSearchIndex<cr>zzzv
nnoremap <silent> N N:call <SID>highlight_current_search()<cr>:ShowSearchIndex<cr>zzzv

function s:SID()
    return matchstr(expand('<sfile>'), '<SNR>\m\zs\d\+\ze_SID$')
endfun

function s:on_command()
  if getcmdtype() == "/" || getcmdtype() == "?"
    return "\<CR>:call <SNR>".s:SID()."_highlight_current_search()\<CR>"
  else
    return "\<CR>"
  endif
endfunction

cnoremap <silent> <expr> <CR> <SID>on_command()

" Search visual selected text
vnoremap / yb/<c-r>"

nnoremap <silent> <Leader>, :nohlsearch<cr>:call <SID>clear_current_search()<cr>

" Disable this because we usually want to use `<c-w>` to delete a word.
"
" function s:insert_keyword_marker()
"   if getcmdtype() == "/" || getcmdtype() == "?"
"     let cmd = getcmdline()
"     let keyword_marker = "\\<\\>\<Left>\<Left>"
"     if empty(cmd)
"       return keyword_marker
"     else
"       return "\<c-u>" . keyword_marker . cmd
"     endif
"   else
"     return "\<c-w>"
"   endif
" endfunction
"
" cnoremap <expr> <c-w> <SID>insert_keyword_marker()
