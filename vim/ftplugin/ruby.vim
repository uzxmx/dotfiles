" This will slow vim
" setlocal foldmethod=syntax

" For ruby file, if not set re to 1, the ruby syntax will be slow
setlocal re=1 

" By default, ale will start brakeman if available. Explicitly only enable
" rubocop to avoid high cpu load.
let b:ale_linters = ['rubocop']

let b:ale_fixers = ['rubocop']

nnoremap <LocalLeader>tn :call RunNearestSpec()<CR>
nnoremap <LocalLeader>tc :call RunCurrentSpecFile()<CR>
nnoremap <LocalLeader>tl :call RunLastSpec()<CR>
nnoremap <LocalLeader>ta :call RunAllSpecs()<CR>
