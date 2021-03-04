function! utils#escape#escape()
  call s:escape()
endfunction

function! utils#escape#unescape()
  call s:escape(0)
endfunction

function! s:escape(...) range
  let escape = a:0 > 0 ? a:1 : 1

  let selection = utils#get_visual_selection()
  let len = strlen(selection)
  let i = 0
  let backslash = 0
  let chars = []
  while i < len
    let char = nr2char(strgetchar(selection, i))
    let i = i + 1

    if escape
      if char == '\' || char == '"' || char == "\n"
        call add(chars, '\')
        if char == "\n" | call add(chars, 'n') | continue | endif
      endif
      call add(chars, char)
    else
      if backslash
        if char == '\' || char == '"'
          call add(chars, char)
        elseif char == 'n'
          call add(chars, "\n")
        else
          throw 'Unsupported character: ' . char
        endif
        let backslash = 0
        continue
      endif

      if char == '\'
        let backslash = 1
      else
        call add(chars, char)
      endif
    endif
  endwhile

  new | setlocal buftype=nofile bufhidden=wipe nobuflisted noswapfile
  call setline(1, split(join(chars, ''), "\n"))
endfunction
