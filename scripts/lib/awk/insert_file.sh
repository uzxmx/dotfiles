#!/bin/sh

# This function helps to insert all lines from an input file at a given line number of another file.
#
# @params:
#   $1: the input file, when `-` is passed, stdin will be used
#   $2: the target line to insert to
#   $3: the line number to insert at
#
# @example
#    awk_insert_file <(ls -l) foo.txt 3
#    awk_insert_file - foo.txt 3 <<EOF
#      bar
#      baz
#    EOF
awk_insert_file() {
  local lineno="$3"
  local tmpfile="$(mktemp)"
  awk -v "lineno=$lineno" '
  {
    if (NR == FNR) {
      a[NR] = $0
      next
    } else if (FNR == lineno) {
      for (i = 1; i <= length(a); i++) {
        printf "%s\n", a[i]
      }
    }
    printf "%s\n", $0
  }
  ' "$1" "$2" >"$tmpfile"
  cp "$tmpfile" "$2"
  rm "$tmpfile"
}
