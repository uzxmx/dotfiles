#!/bin/sh
#
# The purpose of this script is to keep the intermediate path when copying files.
# The -r/-R option of `cp` is not supported, so only file is supported.
#
# Examples:
#
# * Copy two files to /tmp:
#
#     ./cp_with_intermediate_dir.sh foo/bar.txt foo/bar/baz.txt /tmp
#
#     The tree of /tmp will be:
#       - /tmp
#            | foo
#                | bar.txt
#                | bar
#                    | baz.txt
#
# * Copy files whose paths are specified by using pipe:
#
#     git status | grep 'modified' | awk '{ print $2  }' | xargs -J % cp_with_intermediate_dir.sh % /tmp

dest_dir=${@: -1}
for file in ${@:1:`expr $# - 1`}; do
  dest_file="$dest_dir/$file"
  mkdir -p `dirname $dest_file`
  echo "Copy $file to $dest_file"
  cp "$file" "$dest_file"
done
