function! s:toggle_git_ignored(lines) abort
  let g:toggle_git_ignored = 1
endfunction

" TODO use local fzf_action for ctrl-i ?
let g:fzf_action = {
  \ 'ctrl-t': 'tab split',
  \ 'ctrl-x': 'split',
  \ 'ctrl-v': 'vsplit',
  \ 'ctrl-i': function('s:toggle_git_ignored')
  \ }

function s:fzf_git_standard() abort
  call fzf#run(fzf#wrap({ 'source': 'git ls-files --cached --others --exclude-standard | grep -Fxv "$(git ls-files -d | awk -v def=" " "{print} END { if (NR==0) {print def} }")"' }))
endfunction

function s:fzf_git_ignored() abort
  call fzf#run(fzf#wrap({ 'source': 'git ls-files --others --ignored --exclude-standard' }))
endfunction

function! s:on_term_close() abort
  if exists('g:toggle_git_ignored') && g:toggle_git_ignored == 1
    call s:fzf_git_ignored()
    call feedkeys('i')
    unlet g:toggle_git_ignored
  endif
endfunction

if has('nvim')
  function! s:on_term_close_delayed() abort
    call timer_start(5, { -> s:on_term_close() })
  endfunction

  autocmd TermClose * call s:on_term_close_delayed()
endif

" TODO support :GFiles? / :GF? / :GFiles!
command! GFiles call s:fzf_git_standard()
command! -bang -nargs=* Ag call fzf#vim#ag(<q-args>, { 'options': '--delimiter : --nth 4..' }, <bang>0)

nnoremap <silent> <c-p> :execute system('ls -d .git') == ".git\n" ? 'GFiles' : 'Files'<CR>
nnoremap <silent> <c-w>w :Windows<CR>
nnoremap <silent> <c-w><c-w> :Windows<CR>

" <c-m> is the same as <cr>. This command is rarely used, but often executed
" unexpectedly when typing in <cr> mistakenly. So here we comment it.
"
" nnoremap <silent> <c-m> :Marks<CR>
