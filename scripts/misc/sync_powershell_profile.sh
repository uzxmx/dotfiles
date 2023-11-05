#!/usr/bin/env bash
#
# Synchronize PowerShell profile.

set -eo pipefail

. $(dirname "$0")/../lib/utils.sh

srcfile=

username="$(cmd.exe /c 'echo %USERNAME%' 2>/dev/null | sed 's/[[:space:]]$//')"
# if [ "$USE_WINDOWS_TERMINAL_DEV_BUILD" = "1" ]; then
#   dir="/mnt/c/Users/$username/AppData/Local/Packages/WindowsTerminalDev_8wekyb3d8bbwe/LocalState"
# else
#   dir="/mnt/c/Users/$username/AppData/Local/Packages/Microsoft.WindowsTerminal_8wekyb3d8bbwe/LocalState"
# fi
dir="/mnt/c/Users/$username/Documents/PowerShell"
if [ ! -d "$dir" ]; then
  abort "Directory '$dir' doesn't exist."
fi

srcfile="${1:-$HOME/.dotfiles/windows/PowerShell_profile.ps1}"
file="$dir/Microsoft.PowerShell_profile.ps1"
cat | sudo tee "$file" >/dev/null <<EOF
# Automatically generated from $srcfile. DO NOT EDIT.
#
EOF
cat "$srcfile" | sudo tee -a "$file" >/dev/null

echo 'Successful.'
