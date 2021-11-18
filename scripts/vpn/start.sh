source "$vpn_dir/common.sh"

usage_start() {
  cat <<-EOF
Usage: vpn start

Start ipsec VPN for client.
EOF
  exit 1
}

cmd_start() {
  source "$dotfiles_dir/scripts/lib/systemd.sh"
  systemctl_start ipsec
  systemctl_start xl2tpd

  if ! is_ppp_device_available; then
    echo "Wait 2 seconds for ppp device up..."
    sleep 2
    if ! is_ppp_device_available; then
      echo -e "The ppp device is not up, you can retry to start it again, \nor check xl2tpd log by running 'vpn log'.\n"
      echo -e "You can also use below commands to find the problem:\n"
    cat <<-EOF
$> ip addr
$> ip route

$> sudo tcpdump -n -i ppp0
$> curl https://www.google.com
EOF
exit 1
    fi
  fi

  check_env_variable VPN_SERVER_IP

  check_route_command

  local gw="$(ip route | awk '/default/ { print $3 }' | head -1)"
  if echo "$gw" | grep '^ppp0$' &>/dev/null; then
    echo 'It seems that VPN connection has already started.'
    exit 1
  fi
  if ! ip route | grep "^$VPN_SERVER_IP via $gw " &>/dev/null; then
    sudo route add "$VPN_SERVER_IP" gw "$gw"
  fi
  sudo route add default dev ppp0

  if ! cat /etc/resolv.conf | grep '^nameserver 8\.8\.8\.8$' &>/dev/null; then
    sudo sed -i -E 's/^([^#].*)$/#\1/' /etc/resolv.conf
    echo "nameserver 8.8.8.8" | sudo tee -a /etc/resolv.conf >/dev/null
  fi

  echo "VPN started"
}
alias_cmd s start
