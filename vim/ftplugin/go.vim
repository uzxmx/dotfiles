setlocal noexpandtab tabstop=4 shiftwidth=4 

nnoremap <buffer> <silent> <LocalLeader>r :execute 'call Send_to_Tmux("go run ' . expand("%:p") . '\n")'<CR>
nnoremap <buffer> <silent> <LocalLeader>t :execute 'call Send_to_Tmux("go test ' . expand("%:p") . '\n")'<CR>
nnoremap <buffer> <silent> <LocalLeader>g :GoInfo<CR>
