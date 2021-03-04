function! utils#base64#encode()
  call s:base64(0)
endfunction

function! utils#base64#decode()
  call s:base64(1)
endfunction

function! s:base64(decode) range
  if a:decode
    let suffix = '-d'
    let delimiter = ''
  else
    if system('uname -s') =~ 'Darwin'
      let suffix = '' " Mac OSX doesn't support `-w` option
    else
      let suffix = '-w 0' " Disable wrap when encoding
    endif
    let delimiter = "\n"
  endif
  let command = 'echo -n ' . shellescape(utils#get_visual_selection(delimiter), 1) . ' | base64 ' . suffix
  new
  setl buftype=nofile bufhidden=wipe nobuflisted noswapfile
  exe 'read ++bin !' . command
  1d " Delete the first line, which is empty.
endfunction
