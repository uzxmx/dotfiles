usage_net() {
  cat <<-EOF
Usage: bpftrace net <pid>

Monitor network traffic for a specific process.
EOF
  exit 1
}

cmd_net() {
  local pid="$1"
  [ -z "$pid" ] && usage_net

  sudo bpftrace -e "
tracepoint:net:net_dev_xmit      /pid == $pid/ { @tx += args->len; }
tracepoint:net:netif_receive_skb /pid == $pid/ { @rx += args->len; }
interval:s:1 {
  printf(\"TX: %lu B/s  RX: %lu B/s\n\", @tx, @rx);
  clear(@tx); clear(@rx);
}" | stdbuf -o0 awk '{printf "\r%s\033[K", $0; fflush()}'
}
