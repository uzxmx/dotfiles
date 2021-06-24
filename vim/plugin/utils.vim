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
command! PutFileName put =expand('%:t')
command! PutRelativePath put =expand('%')
command! PutRelativeParentPath put =expand('%:h')
command! PutAbsolutePath put =expand('%:p')
command! PutAbsoluteParentPath put =expand('%:p:h')

command! CopyPath call setreg('*', expand('%:p'))

command! Gen call utils#gen()

command! -range Base64Encode <line1>,<line2>call utils#base64#encode()
command! -range Base64Decode <line1>,<line2>call utils#base64#decode()

command! -range Escape <line1>,<line2>call utils#escape#escape()
command! -range EscapeReverse <line1>,<line2>call utils#escape#unescape()
