command! WQ wq
command! Wq wq
command! W w
command! -bang Q q<bang>
command! -bang Qa qa<bang>

" Save previously closed window
augroup bufclosetrack
  au!
  autocmd WinLeave * let g:lastWinName = @%
augroup END
command! -nargs=0 LastWindow exe "split" g:lastWinName

"-------------------------------------------------------------------------------
" Tabpage utils
"-------------------------------------------------------------------------------

autocmd TabLeave * let g:prev_tabpagenr = tabpagenr()
autocmd TabClosed * if exists('g:prev_tabpagenr') && g:prev_tabpagenr == expand("<afile>") | unlet g:prev_tabpagenr | endif

nnoremap <Plug>(go-to-prev-tab) :call utils#tab#go_to_prev_tab()<CR>
nmap <silent> <c-w>P <Plug>(go-to-prev-tab)

" Load buffer in the current window into a new window of a specified tab
command! -nargs=1 MoveToTab call utils#tab#open_in_tab(<q-args>, v:true)
command! -nargs=1 OpenInTab call utils#tab#open_in_tab(<q-args>, v:false)

" Reference http://vimdoc.sourceforge.net/htmldoc/cmdline.html#filename-modifiers
command! CopyFilePath call setreg('*', expand('%'))
command! CopyFileName call setreg('*', expand('%:t'))
command! CopyFilePathAbs call setreg('*', expand('%:p'))
command! CopyFilePathParent call setreg('*', expand('%:h'))
command! CopyFilePathParentAbs call setreg('*', expand('%:p:h'))

command! Gen call utils#gen()

command! -range Base64Encode <line1>,<line2>call utils#base64#encode()
command! -range Base64Decode <line1>,<line2>call utils#base64#decode()

command! -range Escape <line1>,<line2>call utils#escape#escape()
command! -range EscapeReverse <line1>,<line2>call utils#escape#unescape()

" Delete all buffers except the current/named buffer.
command! -nargs=? -complete=buffer -bang BufOnly :call s:bufonly('<args>', 0, '<bang>')
" Delete all buffers except the buffers in the current tab.
command! -nargs=0 -bang BufOnlyTab :call s:bufonly('', 1, '<bang>')

function! s:bufonly(buffer, tab_mode, bang)
  if a:tab_mode
    silent tabonly
    let buffers = tabpagebuflist()
  else
    if a:buffer == ''
      let buffer = bufnr('%')
    elseif (a:buffer + 0) > 0
      let buffer = bufnr(a:buffer + 0)
    else
      let buffer = bufnr(a:buffer)
    endif

    if buffer == -1
      echohl ErrorMsg
      echomsg "No matching buffer for" a:buffer
      echohl None
      return
    endif

    let buffers = [buffer]
  endif

  let last_buffer = bufnr('$')

  let delete_count = 0
  let n = 1
  while n <= last_buffer
    if index(buffers, n) == -1 && buflisted(n)
      if a:bang == '' && getbufvar(n, '&modified')
        echohl ErrorMsg
        echomsg 'No write since last change for buffer (add ! to override)'
        echohl None
      else
        silent exe 'bdel' . a:bang . ' ' . n
        if !buflisted(n)
          let delete_count = delete_count + 1
        endif
      endif
    endif
    let n = n + 1
  endwhile

  if delete_count == 1
    echomsg delete_count "buffer deleted"
  elseif delete_count > 1
    echomsg delete_count "buffers deleted"
  endif
endfunction
