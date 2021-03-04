let s:is_win = has('win32') || has('win64')
if s:is_win
  function! s:call(fn, ...)
    let shellslash = &shellslash
    try
      set noshellslash
      return call(a:fn, a:000)
    finally
      let &shellslash = shellslash
    endtry
  endfunction

  " Return array of shell commands for cmd.exe
  function! s:enc_to_cp(str)
    if !has('iconv')
      return a:str
    endif
    if !exists('s:codepage')
      let s:codepage = libcallnr('kernel32.dll', 'GetACP', 0)
    endif
    return iconv(a:str, &encoding, 'cp'.s:codepage)
  endfunction
  function! s:wrap_cmds(cmds)
    return map([
      \ '@echo off',
      \ 'setlocal enabledelayedexpansion']
    \ + (has('gui_running') ? ['set TERM= > nul'] : [])
    \ + (type(a:cmds) == type([]) ? a:cmds : [a:cmds])
    \ + ['endlocal'],
    \ '<SID>enc_to_cp(v:val."\r")')
  endfunction
else
  function! s:call(fn, ...)
    return call(a:fn, a:000)
  endfunction

  function! s:wrap_cmds(cmds)
    return a:cmds
  endfunction

  function! s:enc_to_cp(str)
    return a:str
  endfunction
endif

function! s:shellescape(arg, ...)
  let shell = get(a:000, 0, s:is_win ? 'cmd.exe' : 'sh')
  if shell =~# 'cmd.exe$'
    return s:shellesc_cmd(a:arg)
  endif
  return s:call('shellescape', a:arg)
endfunction

function! s:getcwd()
  return s:call('getcwd')
endfunction

function! s:tempname()
  return s:call('tempname')
endfunction

function! s:collect(temps) abort
  try
    return filereadable(a:temps.result) ? readfile(a:temps.result) : []
  finally
    for tf in values(a:temps)
      silent! call delete(tf)
    endfor
  endtry
endfunction

function! s:present(dict, ...)
  for key in a:000
    if !empty(get(a:dict, key, ''))
      return 1
    endif
  endfor
  return 0
endfunction

function! s:splittable(dict)
  return s:present(a:dict, 'up', 'down') && &lines > 15 ||
        \ s:present(a:dict, 'left', 'right') && &columns > 40
endfunction

function! s:calc_size(max, val, dict)
  let val = substitute(a:val, '^\~', '', '')
  if val =~ '%$'
    let size = a:max * str2nr(val[:-2]) / 100
  else
    let size = min([a:max, str2nr(val)])
  endif

  return size
endfunction

function! s:getpos()
  return {'tab': tabpagenr(), 'win': winnr(), 'winid': win_getid(), 'cnt': winnr('$'), 'tcnt': tabpagenr('$')}
endfunction

function! s:split(dict)
  let directions = {
  \ 'up':    ['topleft', 'resize', &lines],
  \ 'down':  ['botright', 'resize', &lines],
  \ 'left':  ['vertical topleft', 'vertical resize', &columns],
  \ 'right': ['vertical botright', 'vertical resize', &columns] }
  let ppos = s:getpos()
  try
    if s:present(a:dict, 'window')
      if type(a:dict.window) == type({})
        if !has('nvim') && !has('patch-8.2.191')
          throw 'Vim 8.2.191 or later is required for pop-up window'
        end
        call s:popup(a:dict.window)
      else
        execute 'keepalt' a:dict.window
      endif
    elseif !s:splittable(a:dict)
      execute (tabpagenr()-1).'tabnew'
    else
      for [dir, triple] in items(directions)
        let val = get(a:dict, dir, '')
        if !empty(val)
          let [cmd, resz, max] = triple
          if (dir == 'up' || dir == 'down') && val[0] == '~'
            let sz = s:calc_size(max, val, a:dict)
          else
            let sz = s:calc_size(max, val, {})
          endif
          execute cmd sz.'new'
          execute resz sz
          return [ppos, {}]
        endif
      endfor
    endif
    return [ppos, { '&l:wfw': &l:wfw, '&l:wfh': &l:wfh }]
  finally
    setlocal winfixwidth winfixheight
  endtry
endfunction

function! utils#term#exec(dict, command) abort
  let temps  = { 'result': s:tempname()  }
  let winrest = winrestcmd()
  let pbuf = bufnr('')
  let [ppos, winopts] = s:split(a:dict)
  let termopts = { 'buf': bufnr(''), 'pbuf': pbuf, 'ppos': ppos, 'dict': a:dict, 'temps': temps,
           \ 'winopts': winopts, 'winrest': winrest, 'lines': &lines,
           \ 'columns': &columns, 'command': a:command }
  function! termopts.switch_back(inplace)
    if a:inplace && bufnr('') == self.buf
      if bufexists(self.pbuf)
        execute 'keepalt b' self.pbuf
      endif
      " No other listed buffer
      if bufnr('') == self.buf
        enew
      endif
    endif
  endfunction
  function! termopts.on_exit(id, code, ...)
    if s:getpos() == self.ppos " {'window': 'enew'}
      for [opt, val] in items(self.winopts)
        execute 'let' opt '=' val
      endfor
      call self.switch_back(1)
    else
      if bufnr('') == self.buf
        " We use close instead of bd! since Vim does not close the split when
        " there's no other listed buffer (nvim +'set nobuflisted')
        close
      endif
      silent! execute 'tabnext' self.ppos.tab
      silent! execute self.ppos.win.'wincmd w'
    endif

    if bufexists(self.buf)
      execute 'bd!' self.buf
    endif

    if &lines == self.lines && &columns == self.columns && s:getpos() == self.ppos
      execute self.winrest
    endif

    if has_key(self.dict, 'on_exit')
      let lines = s:collect(self.temps)
      call self.dict['on_exit'](a:code, lines)
    endif
    call self.switch_back(s:getpos() == self.ppos)
  endfunction

  let command = a:command . ' > ' . temps.result
  if has('nvim')
    call termopen(command, termopts)
  else
    if !len(&bufhidden)
      setlocal bufhidden=hide
    endif
    let termopts.buf = term_start([&shell, &shellcmdflag, command], {'curwin': 1, 'exit_cb': function(termopts.on_exit)})
    if !has('patch-8.0.1261') && !has('nvim') && !s:is_win
      call term_wait(termopts.buf, 20)
    endif
  endif
  setlocal nospell bufhidden=wipe nobuflisted nonumber
  startinsert
  return []
endfunction
