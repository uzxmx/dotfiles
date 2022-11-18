#!/bin/sh

# Convert date time such as `Wed Nov 13 14:32:41 CST 2019` to unix timestamp.
convert_en_US_to_unix_time() {
  LANG=en_US.UTF-8 date -j -f "%a %b %d %T %Z %Y" "$1" "+%s"
}

# %A: day of week
convert_unix_timestamp_to_human_readable() {
  if [[ "$OSTYPE" == "linux-gnu"* ]]; then
    date --date "@$1" "+%Y-%m-%d %H:%M:%S"
  elif [[ "$OSTYPE" == "darwin"* ]]; then
    date -r "$1" "+%Y-%m-%d %H:%M:%S"
  fi
}

get_unix_timestamp_ms() {
  if type -p gdate &>/dev/null; then
    gdate +%s%3N
  else
    date +%s%3N
  fi
}
