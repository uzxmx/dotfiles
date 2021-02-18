let test#strategy = "tslime"

nnoremap <silent> <Leader>ts :TestSuite<CR>
nnoremap <silent> <Leader>tf :TestFile<CR>
nnoremap <silent> <Leader>tn :TestNearest<CR>
nnoremap <silent> <Leader>tl :TestLast<CR>

function! s:autodetect_java_runner(cmd)
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

  exe a:cmd
endfunction

au FileType java nnoremap <buffer> <silent> <Leader>ts :call <SID>autodetect_java_runner('TestSuite')<CR>
  \| nnoremap <buffer> <silent> <Leader>tf :call <SID>autodetect_java_runner('TestFile')<CR>
  \| nnoremap <buffer> <silent> <Leader>tn :call <SID>autodetect_java_runner('TestNearest')<CR>
  \| nnoremap <buffer> <silent> <Leader>tl :call <SID>autodetect_java_runner('TestLast')<CR>
