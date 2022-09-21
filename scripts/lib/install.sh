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
#   $3: optional temp dir. One will be generated if not specified
download_and_install() {
  local tmpdir="$3"
  if [ -z "$tmpdir" ]; then
    create_tmpdir tmpdir
  else
    mkdir -p "$tmpdir"
  fi
  local extracted_dir="$tmpdir/extracted"
  if [ ! -f "$tmpdir/checksum.sha256" ]; then
    local path_to_save="$tmpdir/$(basename "$1")"
    "$DOTFILES_DIR/bin/get" "$1" "$path_to_save"
    sha256sum "$path_to_save" | awk '{print $1}' >"$tmpdir/checksum.sha256"
    mkdir -p "$extracted_dir"
    if [[ "$1" =~ \.tar.gz$ ]]; then
      tar zxf "$path_to_save" -C "$extracted_dir"
    elif [[ "$1" =~ \.tar.xz$ ]]; then
      tar Jxf "$path_to_save" -C "$extracted_dir"
    elif [[ "$1" =~ \.zip$ ]]; then
      unzip "$path_to_save" -d "$extracted_dir"
    fi
  fi
  $2 "$extracted_dir"
}

# Download and install by git.
#
# @params
#   $1: git url
#   $2: install function
#   $3: optional temp dir. One will be generated if not specified
download_and_install_by_git() {
  local tmpdir="$3"
  if [ -z "$tmpdir" ]; then
    create_tmpdir tmpdir
  else
    mkdir -p "$tmpdir"
  fi
  git_shallow_clone "$1" "$tmpdir"
  if [ -n "$2" ]; then
    $2 "$tmpdir"
  fi
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
