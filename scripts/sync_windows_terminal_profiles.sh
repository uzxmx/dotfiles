#!/usr/bin/env bash
#
# Synchronize ~/.dotfiles/windows_terminal/profiles.json with C:\Users\%USERNAME%\AppData\Local\Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState\profiles.json

set -e

. $(dirname "$0")/utils.sh

username="$(cmd.exe /c 'echo %USERNAME%' | sed 's/[[:space:]]$//')"
dir="/mnt/c/Users/$username/AppData/Local/Packages/Microsoft.WindowsTerminal_8wekyb3d8bbwe/LocalState"
if [ ! -d "$dir" ]; then
  abort "Directory '$dir' doesn't exist."
fi

file="$dir/profiles.json"
cat >"$file" <<EOF
// Automatically generated from ~/.dotfiles/windows_terminal/profiles.json. DO NOT EDIT.
//
EOF
cat ~/.dotfiles/windows_terminal/profiles.json >>"$file"

echo 'Successful.'
