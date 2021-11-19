usage_log() {
  cat <<-EOF
Usage: iptables log

Tail the kernel log for packets.
EOF
  exit 1
}

cmd_log() {
  tail -F /var/log/kern.log
}
