usage_dns() {
  cat <<-EOF
Usage: net dns

Setup DNS servers.

Subcommands:
  g, get - get DNS servers
  s, set - set DNS servers
EOF
  exit 1
}

cmd_dns() {
  local cmd="$1"
  shift || true
  [ -z "$cmd" ] && usage_dns

  case "$cmd" in
    g | get | s | set)
      case "$cmd" in
        g)
          cmd="get"
          ;;
        s)
          cmd="set"
          ;;
      esac
      case "$1" in
        -h)
          type "usage_dns_$cmd" &>/dev/null && "usage_dns_$cmd"
          ;;
      esac
      "cmd_dns_$cmd" "$@"
      ;;
    *)
      usage_dns
      ;;
  esac
}
alias_cmd d dns

cmd_dns_get() {
  # Get all network services by `networksetup -listallnetworkservices`.
  local networkservice="Wi-Fi"

  networksetup -getdnsservers "$networkservice"
}

usage_dns_set() {
  cat <<-EOF
Usage: net dns set [dns-server...]

Set DNS servers.

If no DNS server is specified, '114.114.114.114' is used.

If you want to clear DNS servers, specify 'empty', e.g. net dns set empty
EOF
  exit 1
}

cmd_dns_set() {
  # Get all network services by `networksetup -listallnetworkservices`.
  local networkservice="Wi-Fi"

  # Public available DNS servers in China include `114.114.114.114`, `114.114.115.115`,
  # and the two `223.5.5.5`, `223.6.6.6` which are from Alibaba Cloud (see https://www.alibabacloud.com/help/zh/alibaba-cloud-public-dns/latest/what-is-alibaba-cloud-public-dns).
  if [ "$#" -eq 0 ]; then
    networksetup -setdnsservers "$networkservice" 114.114.114.114
  else
    networksetup -setdnsservers "$networkservice" "$@"
  fi
}
