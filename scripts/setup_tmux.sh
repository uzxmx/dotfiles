#!/usr/bin/env bash
#
# Setup tmux

set -e

plugins=(
  tmux-plugins/tpm
  tmux-plugins/tmux-sensible
  christoomey/vim-tmux-navigator
)

for plugin in ${plugins[@]}; do
  dir=~/.tmux/plugins/$(basename $plugin)
  if [ -z "$(ls $dir 2>/dev/null || true)" ]; then
    git clone --depth 1 https://github.com/$plugin $dir
  fi
done
