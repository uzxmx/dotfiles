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

function! s:get_visual_selection(...)
  let delimiter = a:0 > 0 ? a:1 : "\n"
  let [line_start, column_start] = getpos("'<")[1:2]
  let [line_end, column_end] = getpos("'>")[1:2]
  let lines = getline(line_start, line_end)
  if len(lines) == 0
      return ''
  endif
  let lines[-1] = lines[-1][: column_end - (&selection == 'inclusive' ? 1 : 2)]
  let lines[0] = lines[0][column_start - 1:]
  return join(lines, delimiter)
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

function! s:escape(...) range
  let escape = a:0 > 0 ? a:1 : 1

  let selection = s:get_visual_selection()
  let len = strlen(selection)
  let i = 0
  let backslash = 0
  let chars = []
  while i < len
    let char = nr2char(strgetchar(selection, i))
    let i = i + 1

    if escape
      if char == '\' || char == '"' || char == "\n"
        call add(chars, '\')
        if char == "\n" | call add(chars, 'n') | continue | endif
      endif
      call add(chars, char)
    else
      if backslash
        if char == '\' || char == '"'
          call add(chars, char)
        elseif char == 'n'
          call add(chars, "\n")
        else
          throw 'Unsupported character: ' . char
        endif
        let backslash = 0
        continue
      endif

      if char == '\'
        let backslash = 1
      else
        call add(chars, char)
      endif
    endif
  endwhile

  new | setlocal buftype=nofile bufhidden=wipe nobuflisted noswapfile
  call setline(1, split(join(chars, ''), "\n"))
endfunction

command! -range Escape <line1>,<line2>call s:escape()
command! -range EscapeReverse <line1>,<line2>call s:escape(0)
