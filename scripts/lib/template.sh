#!/bin/sh

# This function renders a shell template file.
#
# @params:
#   $1: shell template file
render_shell_template_file() {
  eval "echo -e \"$(cat "$1")\""
}
