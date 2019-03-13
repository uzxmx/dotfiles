#!/usr/bin/env bash
#
# Examples:
#
#   ./replace.sh foo bar *.txt
#    ./replace.sh foo bar *.txt
#   find . -name '*.txt' | xargs -J % ./replace.sh foo bar %

if [ $# -lt 3 ]; then
  echo "Usage: $0 <pattern> <replacement> <files...>"
  exit 1
fi

for file in ${@:3:$#}; do
  sed -i.bak "s/$1/$2/g" "$file"
done
