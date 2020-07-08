#!/bin/sh

# Compare two versions with format 'x.y.z'. Return 0 if the first version is
# less than the second, otherwise 1.
#
# @params:
#   $1: the first version
#   $2: the second version
#
# @example
#   version_lt 1.2.3 1.3.4
#   version_lt v1.2.3 1.3.4
#   version_lt V1.2.3 V1.3.4
version_lt() {
  local v1="$(echo $1 | sed 's/^[vV]//')"
  local v2="$(echo $2 | sed 's/^[vV]//')"

  local a1 a2
  split_str_into_array "$v1" . a1
  split_str_into_array "$v2" . a2

  if [ -n "$BASH" ]; then
    if [ "${a1[0]}" -lt "${a2[0]}" ] || [ "${a1[0]}" = "${a2[0]}" -a "${a1[1]}" -lt "${a2[1]}" ] || [ "${a1[0]}" = "${a2[0]}" -a "${a1[1]}" = "${a2[1]}" -a "${a1[2]}" -lt "${a2[2]}" ] ]; then
      return 0
    else
      return 1
    fi
  else
    if [ "${a1[1]}" -lt "${a2[1]}" ] || [ "${a1[1]}" = "${a2[1]}" -a "${a1[2]}" -lt "${a2[2]}" ] || [ "${a1[1]}" = "${a2[1]}" -a "${a1[2]}" = "${a2[2]}" -a "${a1[3]}" -lt "${a2[3]}" ] ]; then
      return 0
    else
      return 1
    fi
  fi
}
