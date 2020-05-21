if !empty($SSH_CONNECTION) || !empty($SSH_TTY) || !empty($SSH_CLIENT)
  let s:b64_table = [
        \ "A","B","C","D","E","F","G","H","I","J","K","L","M","N","O","P",
        \ "Q","R","S","T","U","V","W","X","Y","Z","a","b","c","d","e","f",
        \ "g","h","i","j","k","l","m","n","o","p","q","r","s","t","u","v",
        \ "w","x","y","z","0","1","2","3","4","5","6","7","8","9","+","/"]

  function! s:b64encode(str)
    let bytes = s:str2bytes(a:str)
    let b64 = []
    for i in range(0, len(bytes) - 1, 3)
      let n = bytes[i] * 0x10000
            \ + get(bytes, i + 1, 0) * 0x100
            \ + get(bytes, i + 2, 0)
      call add(b64, s:b64_table[n / 0x40000])
      call add(b64, s:b64_table[n / 0x1000 % 0x40])
      call add(b64, s:b64_table[n / 0x40 % 0x40])
      call add(b64, s:b64_table[n % 0x40])
    endfor
    if len(bytes) % 3 == 1
      let b64[-1] = '='
      let b64[-2] = '='
    endif
    if len(bytes) % 3 == 2
      let b64[-1] = '='
    endif
    return join(b64, '')
  endfun

  function! s:str2bytes(str)
    return map(range(len(a:str)), 'char2nr(a:str[v:val])')
  endfun

  function s:copy(lines, regtype)
    let str = join(a:lines, "\n")
    let jid = jobstart('tmux load-buffer -')
    call chansend(jid, str)
    call chanclose(jid)

    let str = s:b64encode(str)
    call chansend(v:stderr, "\033]52;;" . str . "\007")
  endfunction

  let g:clipboard = {
    \ 'name': 'SSHClipboard',
    \ 'copy': {
    \   '+': function('s:copy'),
    \   '*': function('s:copy'),
    \   },
    \ 'paste': {
    \   '+': 'tmux save-buffer -',
    \   '*': 'tmux save-buffer -',
    \   },
    \ }
endif
