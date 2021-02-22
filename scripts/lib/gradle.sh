#!/bin/sh

dotfiles_dir="$(realpath "$(dirname "$BASH_SOURCE")/../..")"

source "$dotfiles_dir/scripts/lib/utils/find.sh"
gradle_bin="$(find_file_hierarchical gradlew)"

run_task() {
  local script="$1"
  local task="$2"
  shift 2
  local initdir="$HOME/.gradle/init.d"
  mkdir -p "$initdir"
  tmpfile="$initdir/$(basename "$script")-$(date +%Y%m%d%H%M%S).gradle"
  handle_exit() {
    [ -e "$tmpfile" ] && rm "$tmpfile"
  }
  trap handle_exit EXIT
  cp "$dotfiles_dir/gradle/lib/$script" "$tmpfile"
  "$gradle_bin" "$task" "$@"
}
