usage_rule() {
  cat <<-EOF
Usage: ip rule

Manage rules in the routing policy database

Subcommands:
  l, list - list rules
  ensure  - ensure a rule exists
EOF
  exit 1
}

cmd_rule() {
  local cmd="$1"
  shift || true
  if [ -z "$cmd" ]; then
    cmd="list"
  fi

  case "$cmd" in
    l | list | ensure)
      case "$cmd" in
        l)
          cmd="list"
          ;;
      esac
      case "$1" in
        -h)
          type "usage_rule_$cmd" &>/dev/null && "usage_rule_$cmd"
          ;;
      esac
      "cmd_rule_$cmd" "$@"
      ;;
    *)
      usage_rule
      ;;
  esac
}

usage_rule_list() {
  cat <<-EOF
Usage: ip rule list

List rules.
EOF
  exit 1
}

cmd_rule_list() {
  ip rule
}

usage_rule_ensure() {
  cat <<-EOF
Usage: ip rule ensure

Ensure a rule exists.
EOF
  exit 1
}

cmd_rule_ensure() {
  if [ -z "$(ip rule list "$@")" ]; then
    sudo ip rule add "$@"
  fi
}
