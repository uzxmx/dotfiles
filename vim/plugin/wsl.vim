" FIXME has('wsl') doesn't work, but accroding to https://github.com/neovim/neovim/issues/6227#issuecomment-501128566, it should work.
if system('uname -r') =~ 'Microsoft'
  let g:clipboard = {
    \ 'name': 'WSLClipboard',
    \ 'copy': {
    \   '+': 'clip.exe',
    \   '*': 'clip.exe',
    \   },
    \ 'paste': {
    \   '+': 'pbpaste.exe --lf',
    \   '*': 'pbpaste.exe --lf',
    \   },
    \ 'cache_enabled': 1
    \ }
endif
