" Run shell command.
"
" @param str the command string
" @param filetype the scratch buffer file type
" @param quiet if 1, then stderr will be redirected to /dev/null
function! utils#shell#run(str, filetype, quiet) range
  if empty(a:str)
    let cmdline = join(map(range(a:firstline, a:lastline), "substitute(getline(v:val), '\\\\$', '', '')"), '')
  else
    let cmdline = a:str
  endif

  let expanded_cmdline = cmdline
  " Expand filename if argument starts with `%`, `#` or `<`. See `:h filename-modifiers`.
  for part in split(cmdline, ' ')
    if part[0] =~ '\v[%#<]'
      let expanded_part = fnameescape(expand(part))
      let expanded_cmdline = substitute(expanded_cmdline, part, expanded_part, '')
    endif
  endfor

  if a:quiet == 1
    let expanded_cmdline = expanded_cmdline . ' 2>/dev/null'
  endif

  botright new
  setlocal buftype=nofile bufhidden=wipe nobuflisted noswapfile
  execute '$read !' . s:shellescape_special(expanded_cmdline)
  if a:filetype == 'json'
    setlocal ft=json
    execute ':Autoformat'
  endif
  1
endfunction

function! s:shellescape_special(cmd)
  return substitute(substitute(a:cmd, '\([!%#]\)', '\\\1', 'g'), '\(<cword>\)', '\\\1', 'g')
endfunction

function! utils#shell#pipe(str) range
  let output = system('echo ' . shellescape(join(getline(a:firstline, a:lastline), "\n")) . ' | ' . a:str)
  botright new
  setlocal buftype=nofile bufhidden=wipe nobuflisted noswapfile
  call setline(1, split(output, "\n"))
endfunction
