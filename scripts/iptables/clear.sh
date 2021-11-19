usage_clear() {
  cat <<-EOF
Usage: iptables clear

Delete all the rules for all the chains of all tables.
EOF
  exit 1
}

cmd_clear() {
  for table in filter nat mangle raw; do
    iptables -t "$table" -F
  done

  source "$iptables_dir/list.sh"
  cmd_list
}
