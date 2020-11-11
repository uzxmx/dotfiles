#!/usr/bin/env bash
#
# Synchronize ~/.dotfiles/windows_terminal/settings.json with C:\Users\%USERNAME%\AppData\Local\Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState\settings.json

set -eo pipefail

. $(dirname "$0")/utils.sh

username="$(cmd.exe /c 'echo %USERNAME%' | sed 's/[[:space:]]$//')"
if [ "$USE_WINDOWS_TERMINAL_DEV_BUILD" = "1" ]; then
  dir="/mnt/c/Users/$username/AppData/Local/Packages/WindowsTerminalDev_8wekyb3d8bbwe/LocalState"
else
  dir="/mnt/c/Users/$username/AppData/Local/Packages/Microsoft.WindowsTerminal_8wekyb3d8bbwe/LocalState"
fi
if [ ! -d "$dir" ]; then
  abort "Directory '$dir' doesn't exist."
fi

file="$dir/settings.json"
cat >"$file" <<EOF
// Automatically generated from ~/.dotfiles/windows_terminal/settings.json. DO NOT EDIT.
//
EOF
cat ~/.dotfiles/windows_terminal/settings.json >>"$file"

echo 'Successful.'
