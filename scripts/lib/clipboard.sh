#!/bin/sh

# Get clipboard content.
#
# @params:
#   $1: the shell variable name to store the clipboard content
#
# @example:
#   local content
#   get_clipboard content
#
# Ref: https://gist.github.com/burke/5960455
get_clipboard() {
  local name="$1"
  local _clipboard_content
  if [ -n "$SSH_CONNECTION" ]; then
    if nc -z localhost 2225; then
      _clipboard_content="$(nc localhost 2225 </dev/null)"
      eval $name='$_clipboard_content'
    else
      echo 'Cannot get clipboard content. Make sure `launchctl load ~/Library/LaunchAgents/pbpaste.plist` on macOS has been executed, and port 2225 is remote forwarded.'
      exit 1
    fi
  else
    _clipboard_content="$(pbpaste)"
    eval $name='$_clipboard_content'
  fi
}
