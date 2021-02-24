function! s:GitAdd(...)
  if a:0 > 0
    execute 'Git add ' . join(a:000)
  else
    Git add %
  endif
endfunction

command! -nargs=* Gadd call s:GitAdd(<f-args>)
