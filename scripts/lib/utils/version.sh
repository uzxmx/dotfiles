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
#
# @deprecated
#   Use `version_lt_not_constrained` instead.
version_lt() {
  local v1="$(echo $1 | sed 's/^[vV]//')"
  local v2="$(echo $2 | sed 's/^[vV]//')"

  local a1 a2
  split_str_into_array "$v1" . a1
  split_str_into_array "$v2" . a2

  if [ -n "$BASH" ]; then
    if [ "${a1[0]}" -lt "${a2[0]}" ] || [ "${a1[0]}" = "${a2[0]}" -a "${a1[1]}" -lt "${a2[1]}" ] || [ "${a1[0]}" = "${a2[0]}" -a "${a1[1]}" = "${a2[1]}" -a "${a1[2]}" -lt "${a2[2]}" ]; then
      return 0
    else
      return 1
    fi
  else
    if [ "${a1[1]}" -lt "${a2[1]}" ] || [ "${a1[1]}" = "${a2[1]}" -a "${a1[2]}" -lt "${a2[2]}" ] || [ "${a1[1]}" = "${a2[1]}" -a "${a1[2]}" = "${a2[2]}" -a "${a1[3]}" -lt "${a2[3]}" ]; then
      return 0
    else
      return 1
    fi
  fi
}

# Compare two versions for any format, which is implemented by converting all
# non-digit characters to spaces and compare each part. Return 0 if the first
# version is less than the second, otherwise 1.
#
# @params:
#   $1: the first version
#   $2: the second version
#
# @example
#   version_lt_not_constrained v1.2.3 1.3.4
#   version_lt_not_constrained 7.6p1 7.9p1
version_lt_not_constrained() {
  local a1=($(echo "$1" | sed 's/[^0-9]/ /g'))
  local a2=($(echo "$2" | sed 's/[^0-9]/ /g'))

  local idx len1 len2
  if [ -n "$BASH" ]; then
    idx=0
    len1=${#a1[@]}
    len2=${#a2[@]}
  else
    idx=1
    len1=$((${#a1[@]} + 1))
    len2=$((${#a2[@]} + 1))
  fi

  while [ "$idx" -lt "$len1" -a "$idx" -lt "$len2" ]; do
    if [ "${a1[$idx]}" -lt "${a2[$idx]}" ]; then
      return 0
    elif [ "${a1[$idx]}" -gt "${a2[$idx]}" ]; then
      return 1
    fi

    idx=$(($idx + 1))
  done

  [ "$idx" -lt "$len2" ] && return 0
  return 1
}
