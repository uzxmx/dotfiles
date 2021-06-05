#!/bin/sh

# Render a template file written by shell.
#
# @example
#   render_shell_template foo.tpl.sh
render_shell_template() {
  local file="$1"
  eval "echo -e \"$(cat "$file")\"" >"$tmpfile"
}
