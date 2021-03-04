" Run selected text in buffer as shell command and save the output to a scratch buffer.
" http://vim.wikia.com/wiki/Display_output_of_shell_commands_in_new_window
command! -range -complete=shellcmd -nargs=* -bang ShellJSON <line1>,<line2>call utils#shell#run(<q-args>, 'json', <bang>0)
command! -range -complete=shellcmd -nargs=* -bang Shell     <line1>,<line2>call utils#shell#run(<q-args>, '', <bang>0)

" Pipe selected text in buffer as stdin of shell command and save the output to a scratch buffer.
"
" For example:
"
"   `:'<,'>PipeToShell tr a-z A-Z` will make selected characters upper case.
"   `:'<,'>PipeToShell html2pug -d` will convert selected html to pug.
"
command! -range -complete=shellcmd -nargs=* PipeToShell <line1>,<line2>call utils#shell#pipe(<q-args>)

command! -bang FormatJSON call utils#format('json', <bang>0)
