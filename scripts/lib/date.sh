#!/bin/sh

# Convert date time such as `Wed Nov 13 14:32:41 CST 2019` to unix timestamp.
convert_en_US_to_unix_time() {
  LANG=en_US.UTF-8 date -j -f "%a %b %d %T %Z %Y" "$1" "+%s"
}
