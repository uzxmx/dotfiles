let test#strategy = "tslime"

function! s:check_socket()
  try
    let chan_id = sockconnect('tcp', 'localhost:5005')
    if chan_id > 0
      call chanclose(chan_id)
      return 1
    endif
  catch
  endtry
  return 0
endfunction

function! s:on_success()
  exec 'CocCommand java.debug.vimspector.start'
endfunction

function! s:on_timeout()
  echoerr 'timeout for java debug'
endfunction

function! s:test_nearest_debug()
  if &ft == 'java'
    call s:autodetect_java_runner()
    if g:test#java#runner == 'gradletest'
      let args = '--debug-jvm'
      exec 'TestNearest ' args
      let sid = expand('<SID>')
      exe "lua require('utils').retry('" . sid . "check_socket', '" . sid . "on_success', '" . sid . "on_timeout', 2000, 15)"
    else
      echoerr 'Unsupported runner: ' . g:test#java#runner
    endif
  else
    echoerr 'Unsupported filetype: ' . &ft
  endif
endfunction

nnoremap <silent> <Leader>ts :TestSuite<CR>
nnoremap <silent> <Leader>tf :TestFile<CR>
nnoremap <silent> <Leader>tn :TestNearest<CR>
nnoremap <silent> <Leader>tl :TestLast<CR>
nnoremap <silent> <Leader>td :call <SID>test_nearest_debug()<CR>

" Param: Ex command
function! s:autodetect_java_runner(...)
  if !exists('g:test#java#runner')
    let dir = getcwd()
    let old_dir = ''
    while dir != old_dir
      if filereadable(dir . '/pom.xml')
        let g:test#java#runner = 'maventest'
        break
      elseif filereadable(dir . '/build.gradle')
        let g:test#java#runner = 'gradletest'
        break
      endif
      let old_dir = dir
      let dir = fnamemodify(dir, ':h')
    endwhile
  endif

  if a:0 > 0
    exe a:1
  endif
endfunction

au FileType java nnoremap <buffer> <silent> <Leader>ts :call <SID>autodetect_java_runner('TestSuite')<CR>
  \| nnoremap <buffer> <silent> <Leader>tf :call <SID>autodetect_java_runner('TestFile')<CR>
  \| nnoremap <buffer> <silent> <Leader>tn :call <SID>autodetect_java_runner('TestNearest')<CR>
  \| nnoremap <buffer> <silent> <Leader>tl :call <SID>autodetect_java_runner('TestLast')<CR>
