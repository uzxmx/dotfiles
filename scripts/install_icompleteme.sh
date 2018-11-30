#!/usr/bin/env bash
#
# This script will install iCompleteMe vim plugin into ~/.vim/pack/main/start.

set -e

root_dir=~/.vim/pack/main/start
plugin_dir=$root_dir/iCompleteMe

mkdir -p $root_dir

if [ ! -e $plugin_dir ]; then
  git clone --recursive https://github.com/jerrymarino/iCompleteMe.git $plugin_dir || rm -rf $plugin_dir
fi

cd $plugin_dir && ./install.py
