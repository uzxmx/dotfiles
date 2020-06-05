" You will have bad experience for diagnostic messages when it's default 4000.
set updatetime=300

function! s:check_back_space() abort
  let col = col('.') - 1
  return !col || getline('.')[col - 1]  =~# '\s'
endfunction

" Use tab for trigger completion with characters ahead and navigate.
" Use command ':verbose imap <tab>' to make sure tab is not mapped by other plugin.
inoremap <silent><expr> <TAB>
    \ pumvisible() ? "\<C-n>" :
    \ <SID>check_back_space() ? "\<TAB>" :
    \ coc#refresh()
inoremap <expr><S-TAB> pumvisible() ? "\<C-p>" : "\<C-h>"

nmap <Leader>crf <Plug>(coc-references)
nmap <Leader>crn <Plug>(coc-rename)

nnoremap <silent> <Leader>cfx :<C-u>CocFix<CR>
nmap <Leader>cfm <Plug>(coc-format)

nnoremap <silent> <Leader>clc :<C-u>CocList commands<CR>
nnoremap <silent> <Leader>cld :<C-u>CocList diagnostics<CR>
nnoremap <silent> <Leader>cle :<C-u>CocList extensions<CR>
nnoremap <silent> <Leader>clo :<C-u>CocList outline<CR>
nnoremap <silent> <Leader>cls :<C-u>CocList -I symbols<CR>
nnoremap <silent> <Leader>clr :<C-u>CocListResume<CR>
nnoremap <silent> <Leader>co :call CocAction('runCommand', 'editor.action.organizeImport')<CR>
nnoremap <silent> g1 :call CocAction('diagnosticInfo')<CR>

augroup coc_group
    au!
    au FileType java,go,typescript,kotlin,c,cpp nmap <buffer> <silent> <C-]> <Plug>(coc-definition)
    au FileType java,go,typescript,kotlin,c,cpp nnoremap <buffer> <silent> K :call CocAction('doHover')<CR>

    au BufWritePre *.go :call CocAction('format')
    au User CocJumpPlaceholder call CocActionAsync('showSignatureHelp')
augroup END
