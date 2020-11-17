#!/usr/bin/env bash
#
# Synchronize windows terminal settings file.

set -eo pipefail

. $(dirname "$0")/../lib/utils.sh

srcfile=

username="$(cmd.exe /c 'echo %USERNAME%' | sed 's/[[:space:]]$//')"
if [ "$USE_WINDOWS_TERMINAL_DEV_BUILD" = "1" ]; then
  dir="/mnt/c/Users/$username/AppData/Local/Packages/WindowsTerminalDev_8wekyb3d8bbwe/LocalState"
else
  dir="/mnt/c/Users/$username/AppData/Local/Packages/Microsoft.WindowsTerminal_8wekyb3d8bbwe/LocalState"
fi
if [ ! -d "$dir" ]; then
  abort "Directory '$dir' doesn't exist."
fi

srcfile="${1:-$HOME/.dotfiles/windows/terminal_settings.json.ofc}"
file="$dir/settings.json"
cat >"$file" <<EOF
// Automatically generated from $srcfile. DO NOT EDIT.
//
EOF
cat "$srcfile" >>"$file"

echo 'Successful.'
