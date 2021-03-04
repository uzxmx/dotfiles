function! utils#tab#go_to_prev_tab()
  if exists('g:prev_tabpagenr')
    exec 'norm!' g:prev_tabpagenr . 'gt'
  endif
endfunction

function! utils#tab#open_in_tab(tab, close)
  let tabnr = tabpagenr()
  if tabnr == a:tab
    return
  endif

  let bufnr = bufnr('%')
  let winnr = winnr()

  execute 'normal! ' . a:tab . 'gt'
  vsplit
  execute 'buffer ' . bufnr

  if a:close == v:true
    call utils#tab#go_to_prev_tab()
    let prev_tabpagenr = g:prev_tabpagenr

    execute winnr . 'wincmd w' | wincmd c

    " If g:prev_tabpagenr does't exist, that means a tabpage just closed
    " because of last code execution, so we need to set the correct value to
    " g:prev_tabpagenr.
    if !exists('g:prev_tabpagenr')
      let g:prev_tabpagenr = prev_tabpagenr - 1
    endif

    call utils#tab#go_to_prev_tab()
  endif
endfunction
