#!/bin/sh
#
# This script is a composite script which provides useful utilities for
# installing software on different systems.

. $(dirname "$BASH_SOURCE")/tmpfile.sh
. $(dirname "$BASH_SOURCE")/utils.sh
. $(dirname "$BASH_SOURCE")/git.sh
. $(dirname "$BASH_SOURCE")/dmg.sh
. $(dirname "$BASH_SOURCE")/path.sh

# Download package and install.
#
# @params
#   $1: download url
#   $2: install function
download_and_install() {
  local tmpdir
  create_tmpdir tmpdir
  local path_to_save="$tmpdir/$(basename "$1")"
  "$DOTFILES_DIR/bin/cget" "$1" "$path_to_save"
  if [[ "$1" =~ \.tar.gz$ ]]; then
    tar zxf "$path_to_save" -C "$tmpdir"
  fi
  $2 "$tmpdir"
}

# Parse arguments.
remainder=()
_parse_arguments() {
  cat <<EOF
  while [ \$# -gt 0 ]; do
    case "\$1" in
      $1
      -*)
        if type usage &>/dev/null; then
          usage
        else
          echo "Unsupported option '\$1'"
          exit 1
        fi
        ;;
      *)
        remainder+=("\$1")
        ;;
    esac
    shift
  done
EOF
}

eval "$(_parse_arguments "$parse_args")"

set - "${remainder[@]}"
