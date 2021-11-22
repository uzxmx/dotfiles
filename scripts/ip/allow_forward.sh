usage_allow_forward() {
  cat <<-EOF
Usage: ip allow_forward [device]

Allow to forward packets from one NIC to another NIC.

For this to work, you must make sure the packets can be routed to the target
NIC. You can check that by executing 'ip route'.

You can verify if packets are forwarded successfully by:

$> iptables trace -- -s 1.2.3.4
$> iptables trace -- -d 1.2.3.4
$> iptables log
# 10.0.0.1 is the IP address of NIC2, we want packets from NIC2 to be forwarded
# to NIC1 (192.168.0.x/24).
$> socat - TCP4:1.2.3.4:80,bind=10.0.0.1

EOF
  exit 1
}

cmd_allow_forward() {
  local device="$1"
  if [ -z "$device" ]; then
    device="$(ip route list default | grep " dev "| sed -E 's/.+ dev ([^ ]+).*/\1/')"
    [ -z "$device" ] && echo "Cannot find a default device" >&2 && exit 1
  fi

  sudo iptables -t nat -I POSTROUTING -o "$device" -j MASQUERADE
  echo 1 | sudo tee /proc/sys/net/ipv4/ip_forward >/dev/null
}
