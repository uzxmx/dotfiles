source "$cp_dir/common.sh"

usage_tree() {
  cat <<-EOF
Usage: cp tree <files...> <target-dir>

Copy files to a target directory with the intermediate paths kept.

$> cp tree foo/bar.txt foo/bar/baz.txt /tmp

The tree of /tmp will be:
  - /tmp
       | foo
           | bar.txt
           | bar
               | baz.txt
EOF
  exit 1
}

cmd_tree() {
  local dest_dir="${@: -1}"
  local file
  for file in "${@:1:$(($# - 1))}"; do
    copy_with_intermediate_paths "$file" "$dest_dir"
  done
}
