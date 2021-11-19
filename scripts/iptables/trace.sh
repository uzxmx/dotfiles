usage_trace() {
  cat <<-EOF
Usage: iptables trace

Add logs for all the chains of all tables. This can be used to trace how a
packet is delivered in Linux network stack.

Options:
  -p <prefix> e.g. HOST_, NETNS_, can be used to identify the net namespace in the logs
EOF
  exit 1
}

cmd_trace() {
  local prefix
  while [ "$#" -gt 0 ]; do
    case "$1" in
      -p)
        shift
        prefix="$1"
        ;;
      *)
        usage_trace
        ;;
    esac
    shift
  done

  append_log filter INPUT "${prefix}FILTER_INPUT "
  append_log filter FORWARD "${prefix}FILTER_FORWARD "
  append_log filter OUTPUT "${prefix}FILTER_OUTPUT "

  append_log nat PREROUTING "${prefix}NAT_PREROUTE "
  append_log nat INPUT "${prefix}NAT_INPUT "
  append_log nat OUTPUT "${prefix}NAT_OUTPUT "
  append_log nat POSTROUTING "${prefix}NAT_POSTROUTE "

  append_log mangle PREROUTING "${prefix}MANGLE_PREROUTE "
  append_log mangle INPUT "${prefix}MANGLE_INPUT "
  append_log mangle FORWARD "${prefix}MANGLE_FORWARD "
  append_log mangle OUTPUT "${prefix}MANGLE_OUTPUT "
  append_log mangle POSTROUTING "${prefix}MANGLE_POSTROUTE "

  append_log raw PREROUTING "${prefix}RAW_PREROUTE "
  append_log raw OUTPUT "${prefix}RAW_OUTPUT "

  source "$iptables_dir/list.sh"
  cmd_list

  cat <<EOF

Use below command to watch the log:

$> iptables log
EOF
}

append_log() {
  iptables -t "$1" -A "$2" -j LOG --log-prefix "$3"
}
