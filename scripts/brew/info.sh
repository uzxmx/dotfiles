source "$brew_dir/common.sh"

usage_info() {
  cat <<-EOF
Usage: brew info [pkg-name]

Show local package info. If no package is given, it will ask you to
select one by fzf.
EOF
  exit 1
}

cmd_info() {
  if [ "$#" -eq 0 ]; then
    local package
    package="$(select_package)"
    brew info "$package"
  else
    brew info "$@"
  fi
}
alias_cmd i info
