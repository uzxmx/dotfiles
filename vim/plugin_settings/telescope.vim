lua << EOF
local actions = require("telescope.actions")
require('telescope').setup{
  defaults = {
    mappings = {
      i = {
        ["<esc>"] = actions.close,
        ["<C-u>"] = false
      },
    },
  }
}

require('telescope').load_extension('fzf')
EOF

" nmap <Leader><Space> :Telescope find_files<cr>
" nnoremap <Leader><Space> :Commands<cr>
" nnoremap <leader>ff <cmd>Telescope find_files<cr>

nnoremap <Leader><Space> <cmd>lua require('telescope.builtin').find_files()<cr>
nnoremap <Leader>fg <cmd>lua require('telescope.builtin').live_grep()<cr>
nnoremap <Leader>fb <cmd>lua require('telescope.builtin').buffers()<cr>
nnoremap <Leader>fc <cmd>lua require('telescope.builtin').commands()<cr>

" TODO compare https://github.com/LukasPietzschmann/telescope-tabs with https://github.com/TC72/telescope-tele-tabby.nvim
nnoremap <Leader>ft <cmd>lua require('telescope-tabs').list_tabs()<cr>
nnoremap <Leader>fT <cmd>lua require('telescope-tabs').go_to_previous()<cr>
