" We want to execute `vim '+PlugInstall' '+qa'` non-interactively. When
" colorscheme doesn't exist, vim will throw an error and ask us to press
" <enter> to continue. In order to solve this, we can use `silent!`.
function! s:apply_colorscheme()
  if g:current_colorscheme =~ 'solarized \(dark\|light\)$'
    call plug#load('NeoSolarized')
    let s:background = split(g:current_colorscheme)[1]
    exec 'set background=' . s:background
    silent! colorscheme NeoSolarized

    " For IncSearch highlight group, vim-colors-solarized implements as below:
    " exe "hi! IncSearch"      .s:fmt_stnd   .s:fg_orange .s:bg_none
    " On Mac, it works fine that the background is orange, and foreground is
    " black. But on Linux, the background is transparent (NONE), and foreground
    " is orange. It may be caused by `cterm=standout`, so in order to solve
    " this, we have below setting.
    hi IncSearch cterm=NONE ctermfg=0 ctermbg=9
  elseif g:current_colorscheme == 'snazzy'
    call plug#load('vim-snazzy')
    set background=dark
    silent! colorscheme snazzy
  endif

  let g:airline_theme='my_dark'
endfunction

call s:apply_colorscheme()

command! ColorschemeReload call ReloadColorscheme()

function! ReloadColorscheme()
  let l:config = g:vim_home . '/vimrc.before.local'
  if !filereadable(l:config)
    return
  endif
  for l:line in readfile(l:config)
    let l:match = matchstr(l:line, "^let g:current_colorscheme = '\\zs[^']*\\ze'")
    if !empty(l:match)
      let g:current_colorscheme = l:match
      call s:apply_colorscheme()
      return
    endif
  endfor
endfunction

" Use libuv fs_event to watch for external changes (e.g. from set_color_scheme).
" BufWritePost only fires when nvim writes the file itself, not external writes.
if has('nvim') && !get(g:, '_colorscheme_watcher_started', 0)
  let g:_colorscheme_watcher_started = 1
  lua << EOF
  local uv = vim.uv or vim.loop
  local handle = uv.new_fs_event()
  uv.fs_event_start(handle, vim.g.vim_home .. '/vimrc.before.local', {}, function(err)
    if not err then
      vim.schedule(function() vim.fn['ReloadColorscheme']() end)
    end
  end)
EOF
endif
