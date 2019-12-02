" We want to execute `vim '+PlugInstall' '+qa'` non-interactively. When
" colorscheme doesn't exist, vim will throw an error and ask us to press
" <enter> to continue. In order to solve this, we can use `silent!`.
"
" Ref: https://github.com/uzxmx/ansible_playbooks/blob/master/dotfiles.yml
if g:current_colorscheme == 'solarized'
  call plug#load('vim-colors-solarized')
  set background=dark
  silent! colorscheme solarized

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
