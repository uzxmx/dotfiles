if g:current_colorscheme == 'solarized'
  call plug#load('vim-colors-solarized')
  set background=dark
  colorscheme solarized
elseif g:current_colorscheme == 'snazzy'
  call plug#load('vim-snazzy')
  set background=dark
  colorscheme snazzy
endif
