highlight TrailingWhitespace ctermbg=red guibg=#cb4c17
match TrailingWhitespace /\s\+$/
autocmd BufWinEnter * if &modifiable && &ft != 'ctrlsf' | match TrailingWhitespace /\s\+$/ | endif
autocmd InsertEnter * if &modifiable && &ft != 'ctrlsf' | match TrailingWhitespace /\s\+\%#\@<!$/ | endif
autocmd InsertLeave * if &modifiable && &ft != 'ctrlsf' | match TrailingWhitespace /\s\+$/ | endif
autocmd BufWinLeave * call clearmatches()
autocmd FileType ctrlsf call clearmatches()

" For nvim v0.9.2.
" Do not highlight whitespaces when using fzf.
if has('nvim')
  autocmd TermOpen * call clearmatches()
endif

function s:RemoveTrailingWhiteSpace()
  %s/\s*$//
  ''
endfunction

command! RemoveTrailingWhiteSpace call s:RemoveTrailingWhiteSpace()
command! TrimTrailingWhiteSpace call s:RemoveTrailingWhiteSpace()
command! StripTrailingWhiteSpace call s:RemoveTrailingWhiteSpace()
