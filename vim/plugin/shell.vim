" Run selected text in buffer as shell command and save the output to a scratch buffer.
" http://vim.wikia.com/wiki/Display_output_of_shell_commands_in_new_window
command! -range -complete=shellcmd -nargs=* ShellJSON <line1>,<line2>call s:RunShellCommand(<q-args>, 'json', 0)
command! -range -complete=shellcmd -nargs=* QShellJSON <line1>,<line2>call s:RunShellCommand(<q-args>, 'json', 1)
command! -range -complete=shellcmd -nargs=* Shell <line1>,<line2>call s:RunShellCommand(<q-args>, '', 0)
command! -range -complete=shellcmd -nargs=* QShell <line1>,<line2>call s:RunShellCommand(<q-args>, '', 1)
function! s:RunShellCommand(str, filetype, quiet) range
  if empty(a:str)
    let cmdline = join(map(range(a:firstline, a:lastline), "substitute(getline(v:val), '\\\\$', '', '')"), '')
  else
    let cmdline = a:str
  endif

  let expanded_cmdline = cmdline
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
  execute '$read !'. expanded_cmdline
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
"   `:'<,'>PipeToShell html2pug` will convert selected html to pug.
"
command! -range -complete=shellcmd -nargs=* PipeToShell <line1>,<line2>call s:PipeToShell(<q-args>)
function! s:PipeToShell(str) range
  let output = system('echo ' . shellescape(join(getline(a:firstline, a:lastline), "\n")) . ' | ' . a:str)
  botright new
  setlocal buftype=nofile bufhidden=wipe nobuflisted noswapfile
  call setline(1, split(output, "\n"))
endfunction
