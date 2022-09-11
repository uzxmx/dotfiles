usage_info() {
  cat <<-EOF
Usage: acme info [domain]

Show info for an issued certificate. It will ask you to select one by fzf if no
domain is specified.
EOF
  exit 1
}

cmd_info() {
  source "$acme_dir/common.sh"

  local cert="$1"
  if [ -z "$cert" ]; then
    cert="$(select_certificate)"
  fi
  run_acme --info -d "$cert"
}
