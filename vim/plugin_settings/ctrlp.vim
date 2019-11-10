" Exclude ~/.rbenv subdirectories, for .rbenv contains .git directory
" if getcwd() !~ '^'.$HOME.'/.rbenv/'
"   " Ignore files in .gitignore
"   let g:ctrlp_user_command = ['.git', 'cd %s && git ls-files -co --exclude-standard']
" else
"   let g:ctrlp_working_path_mode = ''
" endif
