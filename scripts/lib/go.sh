#!/bin/sh

# Compile go source file if it hasn't been or is newer than the compiled, and
# run it.
#
# @params:
#   $1: path to source file
#   VARARGS: arguments to be passed into the executable
go_run_compiled() {
  local src_file="$1"; shift

  if [ -z "$dotfiles_dir" ]; then
    echo "dotfiles_dir must be defined."
    exit 1
  fi

  local name="$(basename "$src_file" | sed "s/\.go//")"
  local path="$(dirname "$src_file" | sed "s:$dotfiles_dir/::")"
  local executable_path="$dotfiles_dir/tmp/gen/$path/$name"

  if [ ! -e "$executable_path" ]; then
    # For go1.17.3, when go source file depends on third party modules, `go
    # build` only works if `go.mod` exists. So here we need to generate
    # `go.mod` file.

    source "$dotfiles_dir/scripts/lib/tmpfile.sh"
    local tmpdir
    create_tmpdir tmpdir
    cp "$src_file" "$tmpdir"

    cd "$tmpdir" && go mod init github.com/uzxmx/dotfiles &>/dev/null && go mod tidy &>/dev/null && go build -o "$executable_path" "$(basename "$src_file")" &>/dev/null
  fi

  "$executable_path" "$@"
}
