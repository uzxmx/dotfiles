#!/bin/sh

dest_dir=${@: -1}
for file in ${@:1:`expr $# - 1`}; do
  dest_file="$dest_dir/$file"
  mkdir -p `dirname $dest_file`
  cp "$file" "$dest_file"
done
