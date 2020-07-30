let g:ctrlsf_ignore_dir = ["node_modules", "tmp", "log"]

let g:ctrlsf_mapping = {
  \ "split": ["<C-S>", "<C-X>"],
  \ "vsplit": "<C-V>",
  \ "next": "n",
  \ "prev": "N",
  \ }

nmap     <C-F>f <Plug>CtrlSFPrompt
vmap     <C-F>f <Plug>CtrlSFVwordPath
vmap     <C-F>F <Plug>CtrlSFVwordExec
nmap     <C-F>n <Plug>CtrlSFCwordPath
nmap     <C-F>p <Plug>CtrlSFPwordPath
nnoremap <C-F>o :CtrlSFOpen<CR>
nnoremap <C-F>t :CtrlSFToggle<CR>
inoremap <C-F>t <Esc>:CtrlSFToggle<CR>
