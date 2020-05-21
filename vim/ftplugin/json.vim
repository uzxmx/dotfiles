function! s:on_event(job_id, data, event)
  if a:event == 'stdout' || a:event == 'stderr'
    " TODO Here we want to only bother user with messages on error (avoid hit-enter on success).
    " But `set shortmess+=at` seems not working.
    echo join(a:data, "\n")
  endif
endfunction

function! s:sync_windows_terminal_settings()
  let callbacks = {
  \ 'on_stdout': function('s:on_event'),
  \ 'on_stderr': function('s:on_event'),
  \ 'on_exit': function('s:on_event')
  \ }
  let jid = jobstart('~/.dotfiles/scripts/sync_windows_terminal_settings.sh', callbacks)
  call jobwait([jid])
endfunction

augroup windows_terminal_settings
  au!
  autocmd BufWritePost ~/.dotfiles/windows_terminal/settings.json call s:sync_windows_terminal_settings()
augroup END
