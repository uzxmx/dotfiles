usage_stop() {
  cat <<-EOF
Usage: vpn stop

Stop ipsec VPN for client.
EOF
  exit 1
}

cmd_stop() {
  check_route_command

  if ip route | grep "^default dev ppp0" &>/dev/null; then
    sudo route del default dev ppp0
  fi

  sudo sed -i -E '/^nameserver 8.8.8.8$/d' /etc/resolv.conf
  sudo sed -i -E 's/^#(nameserver .+)$/\1/' /etc/resolv.conf

  source "$dotfiles_dir/scripts/lib/systemd.sh"

  systemctl_stop xl2tpd
  systemctl_stop ipsec

  echo "VPN stopped"
}
