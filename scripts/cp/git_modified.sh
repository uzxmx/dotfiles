source "$cp_dir/common.sh"

usage_git_modified() {
  cat <<-EOF
Usage: cp git_modified <target-dir>

Copy modified files in current git repository to a target directory with
the intermediate paths kept.

$> cp git_modified /tmp
EOF
  exit 1
}

cmd_git_modified() {
  local dest_dir="$1"
  local file
  while read file; do
    copy_with_intermediate_paths "$file" "$dest_dir"
  done < <(git status | grep "modified:" | awk '{ print $2 }')
}
