#!/bin/sh

# This function helps to find the target line number in a file.
#
# @params:
#   $1: the target file
#   $2: the target line
#
# @example
#    awk_find_line ~/.m2/settings.xml "</mirrors>"
awk_find_line() {
  awk -v "target=$2" '
  {
    text = $0
    gsub(/^[[:space:]]+|[[:space:]]+$/, "", text)
    if (text == target) {
      print NR
      exit
    }
  }
  ' "$1"
}

# @see awk_find_line_range
awk_find_line_before_and_after() {
  awk -v "target_lineno=$2" -v "target_before=$3" -v "target_after=$4" '
  BEGIN {
    first_lineno = -1
    last_lineno = -1
  }
  {
    text = $0
    gsub(/^[[:space:]]+|[[:space:]]+$/, "", text)
    if (NR < target_lineno && text == target_before) {
      first_lineno = NR
    } else if (NR > target_lineno && text == target_after) {
      last_lineno = NR
      exit
    }
  }
  END {
    if (first_lineno != -1 && last_lineno != -1) {
      printf "%s %s\n", first_lineno, last_lineno
    }
  }
  ' "$1"
}

# This function helps to find the line range which contains the target line.
#
# @params:
#   $1: the target file
#   $2: the target line
#   $3: the line which is closest before the target line
#   $4: the line which is closest after the target line
#
# @example
#    awk_find_line_range ~/.m2/settings.xml "<id>aliyun</id>" "<mirror>" "</mirror>"
#    awk_find_line_range ~/.m2/settings.xml "</mirrors>"
awk_find_line_range() {
  local target_lineno=$(awk_find_line "$1" "$2")
  if [ -n "$target_lineno" ]; then
    awk_find_line_before_and_after "$1" "$target_lineno" "$3" "$4"
  fi
}
