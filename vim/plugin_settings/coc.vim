" Uncomment below if you want to start coc server manually by `:CocStart`.
" let g:coc_start_at_startup = 0

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

nmap <Leader>cre <Plug>(coc-references)
nmap <Leader>ci <Plug>(coc-implementation)
nmap <Leader>ct <Plug>(coc-type-definition)
nmap <Leader>crn <Plug>(coc-rename)
nnoremap <silent> <Leader>cfx :<C-u>CocFix<CR>
nmap <Leader>cfm <Plug>(coc-format)

nmap <leader>crf <Plug>(coc-refactor)

nmap <leader>ca  <Plug>(coc-codeaction)

nnoremap <silent> <Leader>clo :<C-u>CocFzfList outline<CR>
nnoremap <silent> <Leader>cc :<C-u>CocFzfList commands<CR>
" Use `:CocFzfList diagnostics` to show global diagnostics.
nnoremap <silent> <Leader>cd :<C-u>CocFzfList diagnostics --current-buf<CR>

" Search workspace symbols. Use CocList instead of CocFzfList, because the
" former is faster.
" nnoremap <silent> <Leader>cls :<C-u>CocFzfList symbols<CR>
nnoremap <silent> <Leader>cls :<C-u>CocList symbols<CR>

nnoremap <silent> <Leader>co :call CocAction('runCommand', 'editor.action.organizeImport')<CR>
" nnoremap <silent> g1 :call CocAction('diagnosticInfo')<CR>

nmap <silent> <Leader>ch <Plug>(coc-float-hide)

" The original <C-]> mapping for navigating to a tag is useful for rails
" projects, so we don't change its original behavior. Instead, we explicitly
" remap it for specific file types in coc_group.
"
" nmap <C-]> <Plug>(coc-definition)

nnoremap K :call <SID>show_documentation()<CR>

function! s:show_documentation()
  if (index(['vim', 'help'], &filetype) >= 0)
    execute 'h '.expand('<cword>')
  elseif (coc#rpc#ready())
    call CocActionAsync('doHover')
  else
    execute '!' . &keywordprg . " " . expand('<cword>')
  endif
endfunction

" function! s:onCocStatusChange() abort
"   " Only do these mappings when coc indicates it can help.
"   au FileType c,cpp nmap <buffer> <silent> <C-]> <Plug>(coc-definition)
"   au FileType c,cpp nnoremap <buffer> <silent> K :call s:show_documentation()<CR>
" endfunction

augroup coc_group
    au!
    au FileType java,go,typescript,kotlin,swift nmap <buffer> <silent> <C-]> <Plug>(coc-definition)
    " au User CocStatusChange call s:onCocStatusChange()

    au BufWritePre *.go :call CocAction('format')
    au User CocJumpPlaceholder call CocActionAsync('showSignatureHelp')
augroup END

" Map function and class text objects
" NOTE: Requires 'textDocument.documentSymbol' support from the language server.
xmap if <Plug>(coc-funcobj-i)
omap if <Plug>(coc-funcobj-i)
xmap af <Plug>(coc-funcobj-a)
omap af <Plug>(coc-funcobj-a)
xmap ic <Plug>(coc-classobj-i)
omap ic <Plug>(coc-classobj-i)
xmap ac <Plug>(coc-classobj-a)
omap ac <Plug>(coc-classobj-a)
