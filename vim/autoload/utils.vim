" Generate files from templates
function! utils#gen()
  call utils#term#exec({ 'down': '~40%', 'on_exit': function('s:on_gen') }, 'gen --calling-path "' . expand('%:p') . '" --print-output-path')
endfunction

function! s:on_gen(code, lines)
  if a:code == 0
    exe 'vs ' . a:lines[0]
  else
    echomsg join(a:lines)
  endif
endfunction

function! utils#get_visual_selection(...)
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

function utils#format(filetype, bang)
  exec 'set ft=' . a:filetype
  if a:bang
    let saved_mode = g:autoformat_verbosemode
    let g:autoformat_verbosemode = 1
  endif
  Autoformat
  if a:bang
    let g:autoformat_verbosemode = saved_mode
  endif
endfunction
