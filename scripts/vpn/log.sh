usage_log() {
  cat <<-EOF
Usage: vpn log

Show VPN logs.
EOF
  exit 1
}

cmd_log() {
  # TODO add support for non-tmux mode
  if [ -n "$TMUX" ]; then
    tmux split-window -h journalctl -u ipsec -f
  fi

  journalctl -u xl2tpd -f
}
alias_cmd l log
