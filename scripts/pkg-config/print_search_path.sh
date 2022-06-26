usage_print_search_path() {
  cat <<-EOF
Usage: pkg-config print_search_path

Print the search path.
EOF
  exit 1
}

cmd_print_search_path() {
  pkg-config --variable pc_path pkg-config
}
alias_cmd p print_search_path
