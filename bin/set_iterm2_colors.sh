#!/usr/bin/env bash
#
# Change colors for current iterm2 session.

source ~/.dotfiles/scripts/lib/iterm2.sh

presets=(
  "Solarized Dark"
  Snazzy
)
preset=$(IFS=$'\n'; echo "${presets[*]}" | fzf)

if [[ -n "$preset" ]]; then
  emit_code SetColors preset "$preset"
fi
