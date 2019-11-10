" Workaround for caw.vim. If we don't call the below function, caw.vim can not
" detect the context_filetype.vim
" TODO fixme
au BufNewFile,BufRead * call context_filetype#get_filetype()
