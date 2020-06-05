#!/usr/bin/env bash
#
# This script will install YouCompleteMe vim plugin into ~/.vim/pack/main/start. You can
# build specified completer by modifying the options passed in `install.py`.

set -e

root_dir=~/.vim/pack/main/start
plugin_dir=$root_dir/YouCompleteMe

mkdir -p $root_dir

if [ ! -e $plugin_dir ]; then
  git clone --recursive https://github.com/Valloric/YouCompleteMe.git $plugin_dir || rm -rf $plugin_dir
fi

# TODO use for loop to build install arguments
cd $plugin_dir && ./install.py \
  --clang-completer \
  --go-completer \
  --ts-completer
