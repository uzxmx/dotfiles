" Run selected text in buffer as shell command and save the output to a scratch buffer.
" http://vim.wikia.com/wiki/Display_output_of_shell_commands_in_new_window
command! -range -complete=shellcmd -nargs=* -bang ShellJSON <line1>,<line2>call s:RunShellCommand(<q-args>, 'json', <bang>0)
command! -range -complete=shellcmd -nargs=* -bang Shell     <line1>,<line2>call s:RunShellCommand(<q-args>, '', <bang>0)

function! s:shellescape_special(cmd)
  return substitute(substitute(a:cmd, '\([!%#]\)', '\\\1', 'g'), '\(<cword>\)', '\\\1', 'g')
endfunction

" Run shell command.
"
" @param str the command string
" @param filetype the scratch buffer file type
" @param quiet if 1, then stderr will be redirected to /dev/null
function! s:RunShellCommand(str, filetype, quiet) range
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

" Pipe selected text in buffer as stdin of shell command and save the output to a scratch buffer.
"
" For example:
"
"   `:'<,'>PipeToShell tr a-z A-Z` will make selected characters upper case.
"   `:'<,'>PipeToShell html2pug -d` will convert selected html to pug.
"
command! -range -complete=shellcmd -nargs=* PipeToShell <line1>,<line2>call s:PipeToShell(<q-args>)
function! s:PipeToShell(str) range
  let output = system('echo ' . shellescape(join(getline(a:firstline, a:lastline), "\n")) . ' | ' . a:str)
  botright new
  setlocal buftype=nofile bufhidden=wipe nobuflisted noswapfile
  call setline(1, split(output, "\n"))
endfunction

function s:format(filetype, bang)
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
command! -bang FormatJSON call s:format('json', <bang>0)
