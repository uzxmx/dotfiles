#!/usr/bin/env zsh

. $(dirname "$0")/../lib/ssh.sh

ssh_add_identities

# Clear screen instead of merely adding new lines.
# Ref: https://stackoverflow.com/questions/5367068/clear-a-terminal-screen-for-real
clear_screen() {
  clear && echo -en "\e[3J"
}

clear_screen

if [ "$1" = "iTerm2" ]; then
  if [ -n "$ITERM2_COLOR_PRESET" ]; then
    source "$DOTFILES_DIR/scripts/lib/iterm2.sh"
    emit_code SetColors preset "$ITERM2_COLOR_PRESET"
  fi
  echo "Initialized for iTerm2."
fi
