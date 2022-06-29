#!/usr/bin/env bash

dotfiles_dir="$(realpath "$(dirname "$BASH_SOURCE")/..")"

"$dotfiles_dir/scripts/misc/init_session.sh"

[ -f ~/.init.local.sh ] && bash ~/.init.local.sh

exit 0
