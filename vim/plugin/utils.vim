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

function! s:GoToPrevTab()
  if exists('g:prev_tabpagenr')
    exec 'norm!' g:prev_tabpagenr . 'gt'
  endif
endfunction

nnoremap <Plug>(go-to-prev-tab) :call <SID>GoToPrevTab()<CR>
nmap <silent> <c-w>P <Plug>(go-to-prev-tab)

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
    call s:GoToPrevTab()
    let prev_tabpagenr = g:prev_tabpagenr

    execute winnr . 'wincmd w' | wincmd c

    " If g:prev_tabpagenr does't exist, that means a tabpage just closed
    " because of last code execution, so we need to set the correct value to
    " g:prev_tabpagenr.
    if !exists('g:prev_tabpagenr')
      let g:prev_tabpagenr = prev_tabpagenr - 1
    endif

    call s:GoToPrevTab()
  endif
endfunction

" Reference http://vimdoc.sourceforge.net/htmldoc/cmdline.html#filename-modifiers
command! PutFileName put =expand('%:t')
command! PutRelativePath put =expand('%')
command! PutRelativeParentPath put =expand('%:h')
command! PutAbsolutePath put =expand('%:p')
command! PutAbsoluteParentPath put =expand('%:p:h')

" Generate files from templates
function! s:gen()
  call TermExecute({ 'down': '~40%', 'on_exit': function('s:on_gen') }, 'gen --calling-path "' . expand('%:p') . '" --print-output-path')
endfunction

function! s:on_gen(code, lines)
  if a:code == 0
    exe 'vs ' . a:lines[0]
  else
    echomsg join(a:lines)
  endif
endfunction

command! Gen call s:gen()

function! s:get_visual_selection(delimiter)
  let [line_start, column_start] = getpos("'<")[1:2]
  let [line_end, column_end] = getpos("'>")[1:2]
  let lines = getline(line_start, line_end)
  if len(lines) == 0
      return ''
  endif
  let lines[-1] = lines[-1][: column_end - (&selection == 'inclusive' ? 1 : 2)]
  let lines[0] = lines[0][column_start - 1:]
  return join(lines, a:delimiter)
endfunction

function! s:Base64(decode) range
  if a:decode
    let suffix = '-d'
    let delimiter = ''
  else
    let suffix = '-w 0' " Disable wrap when encoding
    let delimiter = "\n"
  endif
  let command = 'echo -n ' . shellescape(s:get_visual_selection(delimiter), 1) . ' | base64 ' . suffix
  new
  setl buftype=nofile bufhidden=wipe nobuflisted noswapfile
  exe 'read ++bin !' . command
  1d " Delete the first line, which is empty.
endfunction

command! -range Base64Encode <line1>,<line2>call s:Base64(0)
command! -range Base64Decode <line1>,<line2>call s:Base64(1)
