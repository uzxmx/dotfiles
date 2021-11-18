usage_config() {
  cat <<-EOF
Usage: vpn config

Config ipsec VPN for client.
EOF
  exit 1
}

cmd_config() {
  # TODO open multiple tabs
  vi "/etc/ipsec.d/main.conf" "/etc/ipsec.d/main.secrets" "/etc/xl2tpd/xl2tpd.conf" "/etc/ppp/options.l2tpd.client"
}
alias_cmd c config
