" Check and install vim-plug automatically
if empty(glob('~/.vim/autoload/plug.vim'))
  silent !curl -fLo ~/.vim/autoload/plug.vim --create-dirs
    \ https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
  " TODO prompt for confirmation to execute PlugInstall
  autocmd VimEnter * PlugInstall --sync | source $MYVIMRC
endif

call plug#begin('~/.vim/plugged')

Plug 'neoclide/coc.nvim', { 'branch': 'release' }
Plug 'fatih/vim-go', { 'do': ':GoInstallBinaries', 'for': 'go' }
Plug 'posva/vim-vue', { 'for': 'vue' }
Plug 'elzr/vim-json', { 'for': 'json' }
Plug 'keith/swift.vim', { 'for': 'swift' }
Plug 'digitaltoad/vim-pug', { 'for': 'pug' }
Plug 'tpope/vim-fugitive', { 'tag': 'v2.3' }
Plug 'airblade/vim-gitgutter'
Plug 'vim-ruby/vim-ruby', { 'for': 'ruby' } " TODO make this faster
" Plug 'tpope/vim-bundler', { 'for': 'ruby' }
Plug 'uzxmx/vim-rails', { 'for': 'ruby' }
" Plug 'tpope/vim-rake', { 'for': 'ruby' }
Plug 'slim-template/vim-slim', { 'for': 'slim' }
Plug 'thoughtbot/vim-rspec', { 'for': 'ruby' }
" Plug 'tpope/vim-dispatch'
Plug 'scrooloose/nerdtree', { 'on': ['NERDTreeToggle', 'NERDTreeFind'] }
augroup nerd_loader
  autocmd!
  autocmd VimEnter * silent! autocmd! FileExplorer
  autocmd BufEnter,BufNew *
        \  if isdirectory(expand('<amatch>'))
        \|   call plug#load('nerdtree')
        \|   execute 'autocmd! nerd_loader'
        \| endif
augroup END
Plug 'tyok/nerdtree-ack', { 'on': ['NERDTreeToggle', 'NERDTreeFind'] }
Plug 'pbrisbin/vim-mkdir'
Plug 'Shougo/context_filetype.vim'
Plug 'tyru/caw.vim'
Plug 'chrisbra/csv.vim', { 'for': 'csv' }
Plug 'w0rp/ale'
Plug 'chiel92/vim-autoformat', { 'on': 'Autoformat' }
Plug 'junegunn/vim-easy-align', { 'on': 'EasyAlign' } " TODO enhance this
Plug 'Yggdroot/indentLine', { 'on': 'IndentLinesEnable' }
Plug 'uzxmx/vim-table-mode', { 'branch': 'feature/insert-table-columns',  'for': 'markdown' }
Plug 'tpope/vim-endwise'
Plug 'alvan/vim-closetag'
Plug 'ervandew/supertab', { 'on': [] } " TODO
Plug 'jiangmiao/auto-pairs' " TODO
" Plug 'ctrlpvim/ctrlp.vim'
Plug 'dyng/ctrlsf.vim'
Plug 'mileszs/ack.vim'
Plug 'henrik/vim-indexed-search' " google/vim-searchindex doesn't work better than henrik/vim-indexed-search.
Plug 'SirVer/ultisnips', { 'on': [] }
Plug 'honza/vim-snippets', { 'on': [] }
Plug 'majutsushi/tagbar', { 'on': ['Tagbar', 'TagbarToggle'] }
Plug 'szw/vim-tags', { 'on': [] } " TODO
Plug 'vim-airline/vim-airline'
Plug 'altercation/vim-colors-solarized'
Plug 'mkitt/tabline.vim'


Plug 'tpope/vim-repeat'
Plug 'uzxmx/vim-projectionist'
Plug 'uzxmx/vim-surround'
Plug 'jgdavey/tslime.vim'
Plug 'christoomey/vim-tmux-navigator'
Plug 'uzxmx/vim-pbcopy', { 'branch': 'feature/nvim-support' } " TODO
Plug 'tpope/vim-tbone'
Plug 'tpope/vim-eunuch'
Plug 'tpope/vim-sensible'
Plug 'tpope/vim-unimpaired'
Plug 'tpope/vim-rsi'
Plug 'tpope/vim-abolish'
Plug 'mattn/emmet-vim', { 'for': 'html' }
Plug 'editorconfig/editorconfig-vim'
Plug 'fidian/hexmode', { 'on': ['Hexmode'] }
Plug 'uzxmx/Match-Bracket-for-Objective-C', { 'for': 'objc' }
Plug 'vim-scripts/VisIncr', { 'on': ['I'] }

" This plugin causes the menu of nerdtree to show with an annoying delay.
" Plug 'kshenoy/vim-signature' 

Plug 'junegunn/fzf', { 'do': './install --all' }
Plug 'junegunn/fzf.vim'

call plug#end()

augroup load_on_insert
  autocmd!
  autocmd InsertEnter * call plug#load('ervandew/supertab', 'SirVer/ultisnips', 'honza/vim-snippets')
                     \| autocmd! load_on_insert
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

" Load plugin manually
command! -complete=custom,s:list_plugins -nargs=+ PlugLoad call plug#load(<q-args>)
nnoremap <leader>l :PlugLoad<space>
