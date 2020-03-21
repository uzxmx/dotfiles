" Check and install vim-plug automatically
if empty(glob('~/.vim/autoload/plug.vim'))
  silent !curl -fLo ~/.vim/autoload/plug.vim --create-dirs
    \ https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
  " TODO prompt for confirmation to execute PlugInstall
  autocmd VimEnter * PlugInstall --sync | source $MYVIMRC
endif

call plug#begin('~/.vim/plugged')

Plug 'neoclide/coc.nvim', { 'branch': 'release' }
Plug 'posva/vim-vue', { 'for': 'vue' }
Plug 'elzr/vim-json', { 'for': 'json' }
Plug 'keith/swift.vim', { 'for': 'swift' }
Plug 'digitaltoad/vim-pug', { 'for': 'pug' }
Plug 'tpope/vim-fugitive', { 'tag': 'v2.3' }
Plug 'airblade/vim-gitgutter'
Plug 'vim-ruby/vim-ruby', { 'for': 'ruby' } " TODO make this faster
Plug 'uzxmx/vim-rails', { 'for': 'ruby' }
Plug 'slim-template/vim-slim', { 'for': 'slim' }
Plug 'scrooloose/nerdtree', { 'on': ['NERDTree', 'NERDTreeToggle', 'NERDTreeFind'] }
Plug 'tyok/nerdtree-ack', { 'on': ['NERDTree', 'NERDTreeToggle', 'NERDTreeFind'] }
Plug 'pbrisbin/vim-mkdir'
Plug 'Shougo/context_filetype.vim'
Plug 'tyru/caw.vim'
Plug 'chrisbra/csv.vim', { 'for': 'csv' }
Plug 'chiel92/vim-autoformat', { 'on': 'Autoformat' }
Plug 'junegunn/vim-easy-align', { 'on': 'EasyAlign' } " TODO enhance this
Plug 'Yggdroot/indentLine', { 'on': 'IndentLinesEnable' }
Plug 'uzxmx/vim-table-mode', { 'branch': 'feature/insert-table-columns',  'for': 'markdown' }
Plug 'tpope/vim-endwise'
Plug 'alvan/vim-closetag'
Plug 'jiangmiao/auto-pairs'
Plug 'dyng/ctrlsf.vim'
Plug 'mileszs/ack.vim'
Plug 'henrik/vim-indexed-search' " google/vim-searchindex doesn't work better than henrik/vim-indexed-search.
Plug 'SirVer/ultisnips'
Plug 'honza/vim-snippets'
Plug 'majutsushi/tagbar', { 'on': ['Tagbar', 'TagbarToggle'] }
Plug 'szw/vim-tags', { 'on': [] }
Plug 'vim-airline/vim-airline'
Plug 'altercation/vim-colors-solarized', { 'on': [] }
Plug 'uzxmx/vim-snazzy', { 'on': [] }
Plug 'mkitt/tabline.vim'
Plug 'tpope/vim-repeat'
Plug 'uzxmx/vim-projectionist'
Plug 'uzxmx/vim-surround'
Plug 'jgdavey/tslime.vim'
Plug 'christoomey/vim-tmux-navigator'
Plug 'uzxmx/vim-pbcopy', { 'branch': 'feature/nvim-support' }
Plug 'tpope/vim-tbone'
Plug 'tpope/vim-eunuch'
Plug 'tpope/vim-sensible'
Plug 'tpope/vim-unimpaired'
Plug 'tpope/vim-rsi'
Plug 'tpope/vim-abolish'
Plug 'tpope/vim-scriptease'
Plug 'mattn/emmet-vim', { 'for': 'html' }
Plug 'editorconfig/editorconfig-vim'
Plug 'fidian/hexmode', { 'on': ['Hexmode'] }
Plug 'uzxmx/Match-Bracket-for-Objective-C', { 'for': 'objc' }
Plug 'vim-scripts/VisIncr', { 'on': ['I'] }

" This plugin causes the menu of nerdtree to show with an annoying delay.
" Plug 'kshenoy/vim-signature'

Plug 'junegunn/fzf', { 'do': './install --all' }
Plug 'junegunn/fzf.vim', { 'branch': '48a2d80' }

" Plug 'ctrlpvim/ctrlp.vim'

Plug 'janko/vim-test'
Plug 'HerringtonDarkholme/yats.vim'
Plug 'udalov/kotlin-vim'

Plug 'iamcco/markdown-preview.nvim', { 'do': { -> mkdp#util#install() } }

call plug#end()

augroup nerd_loader
  autocmd!
  autocmd VimEnter * silent! autocmd! FileExplorer
  autocmd BufEnter,BufNew *
        \  if isdirectory(expand('<amatch>'))
        \|   call plug#load('nerdtree')
        \|   execute 'autocmd! nerd_loader'
        \| endif
augroup END

" I want to filter out unloaded plugins, but vim-plug doesn't expose s:loaded
" variable. So the easiest way is to just return all plugins.
function! s:list_plugins(A, L, P)
  let specified = split(a:L, " ")[1:]
  let list = []
  for item in keys(g:plugs)
    if index(specified, item) == -1
      call add(list, item)
    endif
  endfor
  return join(list, "\n")
endfunction

" Load plugins manually.
command! -complete=custom,s:list_plugins -nargs=+ PlugLoad call plug#load(<q-args>)
nnoremap <leader>pl :PlugLoad<space>
