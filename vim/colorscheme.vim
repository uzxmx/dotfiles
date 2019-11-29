" We want to execute `vim '+PlugInstall' '+qa'` non-interactively. When
" colorscheme doesn't exist, vim will throw an error and ask us to press
" <enter> to continue. In order to solve this, we can use `silent!`.
"
" Ref: https://github.com/uzxmx/ansible_playbooks/blob/master/dotfiles.yml
if g:current_colorscheme == 'solarized'
  call plug#load('vim-colors-solarized')
  set background=dark
  silent! colorscheme solarized
elseif g:current_colorscheme == 'snazzy'
  call plug#load('vim-snazzy')
  set background=dark
  silent! colorscheme snazzy
endif
