" This plugin can run command when a file is saved, so you can do
" automatic things that depend on the file.
"
" To do so, you need:
"   * The name of the file should end with `.ofc`.
"   * Vim modeline should be on and modelines should have a proper value.
"   * Add a line within modelines range like `# on-file-change: <run some command as in a shell>`.
"     Substitute the bracket part with your own command.
"   * You can use `__FILE__` in the command, which will be substituted with
"     the absolute path to the editing file before running the command.
"
" Note:
"   * You can update the command without reloading vim buffer, because it
"     parses the command every time you save the file.
"   * You can add multiple `on-file-change` line in a file, each of them will
"     be executed in order.

if exists('g:loaded_on_file_change') | finish | endif
let g:loaded_on_file_change = 1

let s:modeline_pat = '[oO][nN]-[fF][iI][lL][eE]-[cC][hH][aA][nN][gG][eE]\s*:\s*\zs.*$'

function! s:ofc_check()
  if !&modeline || &modelines <= 0 | return | endif

  let e1 = &modelines
  let s2 = line('$') - &modelines + 1
  if e1 >= s2
    call s:ofc_check_range(1, line('$'))
  else
    call s:ofc_check_range(1, e1)
    call s:ofc_check_range(s2, line('$'))
  endif
endfunction

function! s:ofc_check_range(start_line, end_line)
  let i = a:start_line
  let file = expand('%:p')
  while i <= a:end_line
    let str = matchstr(getline(i), s:modeline_pat)
    if !empty(str)
      echo system(substitute(str, '__FILE__', file, 'g'))
    endif
    let i = i + 1
  endwhile
endfunction

au BufWritePost *.ofc call s:ofc_check()
