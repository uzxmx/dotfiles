let g:vimspector_sign_priority = {
  \ 'vimspectorBP':         100,
  \ 'vimspectorBPDisabled': 100,
  \ }

nmap <F5> <Plug>VimspectorContinue
nmap <F9> <Plug>VimspectorToggleBreakpoint
nmap <F10> <Plug>VimspectorStepOver
" For Mac OSX, you need to go to settings > keyboard > shortcuts to uncheck F11.
nmap <F11> <Plug>VimspectorStepInto
nmap <F12> <Plug>VimspectorStepOut
