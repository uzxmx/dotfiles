#!/usr/bin/env zsh

. $(dirname "$0")/lib/ssh.sh

ssh_add_identities

# Clear screen instead of merely adding new lines.
# Ref: https://stackoverflow.com/questions/5367068/clear-a-terminal-screen-for-real
clear_screen() {
  clear && echo -en "\e[3J"
}

clear_screen
