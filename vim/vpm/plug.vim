" Check and install vim-plug automatically
if empty(glob('~/.vim/autoload/plug.vim'))
  silent !curl -fLo ~/.vim/autoload/plug.vim --create-dirs
    \ https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
  autocmd VimEnter * PlugInstall --sync | source $MYVIMRC
endif

call plug#begin('~/.vim/plugged')

" == Languages

" Go development plugin for Vim
Plug 'fatih/vim-go', { 'do': ':GoInstallBinaries', 'for': 'go' }

" Syntax Highlight for Vue.js components
Plug 'posva/vim-vue', { 'for': 'vue' }

" groovy indent script 
Plug 'vim-scripts/groovyindent-unix', { 'for': 'groovy' }

" highlights logstash configuration files
Plug 'robbles/logstash.vim', { 'for': 'logstash' }

" distinct highlighting of keywords vs values, JSON-specific (non-JS) warnings, quote concealing. Pathogen-friendly.
Plug 'elzr/vim-json', { 'for': 'json' }

" Swift
Plug 'keith/swift.vim', { 'for': 'swift' }

" Vim syntax highlighting for Pug (formerly Jade) templates.
Plug 'digitaltoad/vim-pug', { 'for': 'pug' }

" == Git
" A Git wrapper so awesome, it should be illegal 
Plug 'tpope/vim-fugitive', { 'tag': 'v2.3' }

" A Vim plugin which shows a git diff in the gutter (sign column) and stages/undoes hunks.
Plug 'airblade/vim-gitgutter'

" == Ruby

" Vim/Ruby Configuration Files
" TODO make this faster
Plug 'vim-ruby/vim-ruby', { 'for': 'ruby' }

" Lightweight support for Ruby's Bundle
" Plug 'tpope/vim-bundler', { 'for': 'ruby' }

" Ruby on Rails power tools
Plug 'uzxmx/vim-rails', { 'for': 'ruby' }

" it's like rails.vim without the rails
" Plug 'tpope/vim-rake', { 'for': 'ruby' }

" slim syntax highlighting for vim.
Plug 'slim-template/vim-slim', { 'for': 'slim' }

" Run Rspec specs from Vim 
Plug 'thoughtbot/vim-rspec', { 'for': 'ruby' }

" == Build

" Asynchronous build and test dispatcher
" TODO do i need this?
" Plug 'tpope/vim-dispatch'

" == File and Directory

" A tree explorer plugin for vim.
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

" This plugin add capability to search in folders via NERDtree.
Plug 'tyok/nerdtree-ack', { 'on': ['NERDTreeToggle', 'NERDTreeFind'] }

" Automatically create any non-existent directories before writing the buffer.
Plug 'pbrisbin/vim-mkdir'

" == Filetype

" Context filetype library for Vim script
Plug 'Shougo/context_filetype.vim'

" Vim comment plugin: supported operator/non-operator mappings, repeatable by dot-command
Plug 'tyru/caw.vim'

" A Filetype plugin for csv files
Plug 'chrisbra/csv.vim', { 'for': 'csv' }

" == Lint/Format

" Asynchronous Lint Engine
" Plug 'w0rp/ale'

" Provide easy code formatting in Vim by integrating existing code formatters.
Plug 'chiel92/vim-autoformat', { 'on': 'Autoformat' }

" Align text
Plug 'godlygeek/tabular'

" A simple, easy-to-use Vim alignment plugin.
Plug 'junegunn/vim-easy-align', { 'on': 'EasyAlign' }

" A vim plugin to display the indention levels with thin vertical lines
Plug 'Yggdroot/indentLine', { 'on': 'IndentLinesEnable' }

" TODO https://github.com/dhruvasagar/vim-table-mode/issues/130 how to insert a new column
" An awesome automatic table creator & formatter allowing one to create neat tables as you type.
Plug 'dhruvasagar/vim-table-mode', { 'for': 'markdown' }

" == Autocomplete

" Insert or delete brackets, parens, quotes in pair.
Plug 'jiangmiao/auto-pairs'

" wisely add "end" in ruby, endfunction/endif/more in vim script, etc
Plug 'tpope/vim-endwise'

" Auto close (X)HTML tags
Plug 'alvan/vim-closetag'

" Perform all your vim insert mode completions with Tab
Plug 'ervandew/supertab', { 'on': [] }

" Yet Another Remote Plugin Framework for Neovim
Plug 'roxma/nvim-yarp'

Plug 'roxma/vim-hug-neovim-rpc'

" Dark powered asynchronous completion framework for neovim/Vim8
" Depends on roxma/nvim-yarp and roxma/vim-hug-neovim-rpc
Plug 'Shougo/deoplete.nvim'

" == Find
"
" Full path fuzzy file, buffer, mru, tag finder for Vim.
" Plug 'ctrlpvim/ctrlp.vim'

" An ack.vim alternative mimics Ctrl-Shift-F on Sublime Text 2
Plug 'dyng/ctrlsf.vim'

" Vim plugin for the Perl module / CLI script 'ack'
" Need to install ack or ag.
Plug 'mileszs/ack.vim'

" Show status when searching.
" google/vim-searchindex doesn't work better than henrik/vim-indexed-search.
Plug 'henrik/vim-indexed-search'

" == Snippets

" The ultimate snippet solution for Vim.
Plug 'SirVer/ultisnips', { 'on': [] }

" vim-snipmate default snippets
Plug 'honza/vim-snippets', { 'on': [] }

" == Tags

" Vim plugin that displays tags in a window, ordered by scope
Plug 'majutsushi/tagbar', { 'on': ['Tagbar', 'TagbarToggle'] }

" Ctags generator for Vim
Plug 'szw/vim-tags', { 'on': [] }

" == UI layout

" lean & mean status/tabline for vim that's light as air
Plug 'vim-airline/vim-airline'

" precision colorscheme for the vim text editor 
Plug 'altercation/vim-colors-solarized'

" A 24bit colorscheme for Vim, Airline and Lightline
" Plug 'jacoborus/tender.vim'

" Configure tabs within Terminal Vim
Plug 'mkitt/tabline.vim'

" == Utils

" enable repeating supported plugin maps with "."
Plug 'tpope/vim-repeat'

" Granular project configuration
Plug 'uzxmx/vim-projectionist'

" quoting/parenthesizing made simple
Plug 'uzxmx/vim-surround'

" Send command from vim to a running tmux session
Plug 'jgdavey/tslime.vim'

" Seamless navigation between tmux panes and vim splits
Plug 'christoomey/vim-tmux-navigator'

" Pipe a visual selection to Mac OS X's pbcopy utility
Plug 'ahw/vim-pbcopy'

" tmux basics
Plug 'tpope/vim-tbone'

" Helpers for UNIX
Plug 'tpope/vim-eunuch'

" Defaults everyone can agree on
Plug 'tpope/vim-sensible'

" Pairs of handy bracket mappings
Plug 'tpope/vim-unimpaired'

" Readline style insertion
Plug 'tpope/vim-rsi'

" Substitution made easy
Plug 'tpope/vim-abolish'

" emmet-vim is a vim plug-in which provides support for expanding abbreviations similar to emmet.
Plug 'mattn/emmet-vim', { 'for': 'html' }

Plug 'editorconfig/editorconfig-vim'

" Hex editing in Vim
" Also see http://vim.wikia.com/wiki/Hex_dump
Plug 'fidian/hexmode', { 'on': ['Hexmode'] }

" TextMate's "Insert Matching Start Bracket" feature implemented in vim script. Makes it a lot more pleasant to write Objective-C.
Plug 'uzxmx/Match-Bracket-for-Objective-C', { 'for': 'objc' }

" Making a column of increasing or decreasing numbers, dates, or daynames.
Plug 'vim-scripts/VisIncr', { 'on': ['I'] }

" The word-based column text-object makes operating on columns of code conceptually simpler and reduces keystrokes.
" TODO Can be removed
" Plug 'coderifous/textobj-word-column.vim', { 'on': [] }

" == Navigation

" Plugin to toggle, display and navigate marks
Plug 'kshenoy/vim-signature'

" == Plugin development

" A Vim plugin for Vim plugins
Plug 'tpope/vim-scriptease', { 'on': ['PP'] }

" Vim plugin: Define your own operator easily
" TODO Can be removed
" Plug 'kana/vim-operator-user', { 'on': [] }
" Plug 'haya14busa/vim-operator-flashy', { 'on': [] }

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
