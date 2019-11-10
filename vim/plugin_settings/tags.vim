" vim-tags related settings
" TODO on mac osx, tags file content will be changed, results in tag not
" found.
let g:vim_tags_main_file = '.tags'
" For mac osx, we use ctags of HEAD version to support generating tags for
" objc project, because stable version don't support it.
if has('macunix')
  let g:vim_tags_ctags_binary = 'ctags --languages=objectivec --langmap=objectivec:.h.m'
endif
" }}}
