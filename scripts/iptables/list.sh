usage_list() {
  cat <<-EOF
Usage: iptables list

List all the rules for all the chains of all tables.
EOF
  exit 1
}

cmd_list() {
  for table in filter nat mangle raw; do
    echo "==== table $table ===="
    iptables -t "$table" -L -n
  done
}
alias_cmd l list
