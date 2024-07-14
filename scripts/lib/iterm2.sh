#!/bin/sh

# Emit proprietary escape codes. Note that the effect scope is current iterm2 session(current tab),
# when opening a new tab, that effect will be lost.
#
# @params:
#   $1: the code name
#   VARARGS: params that the code name needs
#
# @example
#   emit_code SetColors preset Snazzy
#
# @ref
#   https://www.iterm2.com/documentation-escape-codes.html
#   https://github.com/tmux/tmux/issues/482
emit_code() {
  local code_name="$1"
  shift
  local code
  case "$code_name" in
    SetColors)
      code="1337;SetColors=%s=%s"
      ;;
    *)
      echo "Unknown code name: $code_name"
      exit 1
  esac

  code="\033]${code}\a"

  # TODO this seems not working any more.
  if [ -n "$TMUX" ]; then
    code="\033Ptmux;\033${code}\033\\"
  fi

  printf "$code" "$@"
}

open_new_tab_and_run_vi() {
  osascript \
    -e 'tell application "iTerm" to activate' \
    -e 'tell application "System Events" to tell process "iTerm" to keystroke "t" using command down' \
    -e 'delay 0.2' \
    -e "tell application \"System Events\" to tell process \"iTerm\" to keystroke \"exec vi $1\"" \
    -e 'tell application "System Events" to tell process "iTerm" to key code 52'
}
