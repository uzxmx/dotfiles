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
command! -nargs=0 LastWindow call s:LastWindow()
function! s:LastWindow()
  exe "split " . g:lastWinName
endfunction

" Load buffer in the current window into a new window of a specified tab
command! -nargs=1 MoveToTab call s:OpenInTab(<q-args>, v:true)
command! -nargs=1 OpenInTab call s:OpenInTab(<q-args>, v:false)
function! s:OpenInTab(tab, close)
  let tabnr = tabpagenr()
  if tabnr == a:tab
    return
  endif

  let bufnr = bufnr('%')
  let winnr = winnr()

  execute 'normal! ' . a:tab . 'gt'
  vsplit
  execute 'buffer ' . bufnr

  if a:close == v:true
    tabprevious
    execute winnr . 'wincmd w' | wincmd c
    tabnext
  endif
endfunction

" Reference http://vimdoc.sourceforge.net/htmldoc/cmdline.html#filename-modifiers
command! PutFileName put =expand('%:t')
command! PutRelativePath put =expand('%')
command! PutRelativeParentPath put =expand('%:h')
command! PutAbsolutePath put =expand('%:p')
command! PutAbsoluteParentPath put =expand('%:p:h')
