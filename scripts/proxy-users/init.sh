usage_init() {
  cat <<-EOF
Usage: proxy-users init --host <ip-or-domain> [options]

One-time setup: generate Reality keys, render the Xray config, install and
start the systemd service, then print the mihomo snippet to merge.

Options:
  --host <addr>       public IP or domain friends will connect to (required)
  --sni <domain>      Reality camouflage SNI (default: www.cloudflare.com)
                      NOTE: avoid www.microsoft.com — its TLS cert chain
                      exceeds Xray's 8192-byte limit and breaks the handshake
  --port <port>       inbound port (default: 8443)
  --socks-addr <ip>   mihomo socks address (default: 127.0.0.1)
  --socks-port <port> mihomo socks port (default: 7890)

Example:
  proxy-users init --host 1.2.3.4
  proxy-users init --host vps.example.com --sni www.apple.com
EOF
  exit 1
}

cmd_init() {
  need xray; need jq; need openssl

  local host="" sni="www.cloudflare.com" port=8443 socks_addr="127.0.0.1" socks_port=7890
  while [ "$#" -gt 0 ]; do
    case "$1" in
      --host) host="$2"; shift ;;
      --sni) sni="$2"; shift ;;
      --port) port="$2"; shift ;;
      --socks-addr) socks_addr="$2"; shift ;;
      --socks-port) socks_port="$2"; shift ;;
      -h) usage_init ;;
      *) die "Unknown argument '$1'" ;;
    esac
    shift
  done
  [ -z "$host" ] && usage_init

  if priv test -f "$PROXY_USERS_CONFIG"; then
    die "Config already exists at $PROXY_USERS_CONFIG. Remove it first to re-init."
  fi

  echo "Generating Reality key pair..."
  local keys privkey pubkey short_id
  keys="$(xray x25519)"
  privkey="$(sed -n 's/.*[Pp]rivate.*: *//p' <<<"$keys")"
  pubkey="$(sed -n 's/.*[Pp]ublic.*: *//p' <<<"$keys")"
  [ -z "$privkey" ] || [ -z "$pubkey" ] && die "Failed to parse 'xray x25519' output"
  short_id="$(openssl rand -hex 8)"

  local pass_hk pass_jp pass_us pass_local
  pass_hk="$(openssl rand -hex 12)"
  pass_jp="$(openssl rand -hex 12)"
  pass_us="$(openssl rand -hex 12)"
  pass_local="$(openssl rand -hex 12)"

  priv mkdir -p "$PROXY_USERS_DIR"

  echo "Rendering Xray config -> $PROXY_USERS_CONFIG"
  jq \
    --arg pk "$privkey" --arg sid "$short_id" --arg sni "$sni" \
    --argjson port "$port" --arg saddr "$socks_addr" --argjson sport "$socks_port" \
    --arg hk "$pass_hk" --arg jp "$pass_jp" --arg us "$pass_us" '
    (.inbounds[] | select(.tag=="vless-in")) |= (
      .port = $port
      | .streamSettings.realitySettings.privateKey = $pk
      | .streamSettings.realitySettings.shortIds = [$sid]
      | .streamSettings.realitySettings.serverNames = [$sni]
      | .streamSettings.realitySettings.dest = ($sni + ":443")
    )
    | (.outbounds[] | select(.tag=="n-hk") | .settings.servers[0]) |= (.address=$saddr | .port=$sport | .users[0].pass=$hk)
    | (.outbounds[] | select(.tag=="n-jp") | .settings.servers[0]) |= (.address=$saddr | .port=$sport | .users[0].pass=$jp)
    | (.outbounds[] | select(.tag=="n-us") | .settings.servers[0]) |= (.address=$saddr | .port=$sport | .users[0].pass=$us)
  ' "$PU_TEMPLATE" | write_config

  echo "Writing metadata -> $PROXY_USERS_META"
  jq -n \
    --arg host "$host" --arg sni "$sni" --argjson port "$port" \
    --arg pub "$pubkey" --arg sid "$short_id" \
    --arg hk "$pass_hk" --arg jp "$pass_jp" --arg us "$pass_us" --arg local "$pass_local" '
    { host: $host, sni: $sni, port: $port, public_key: $pub, short_id: $sid,
      socks_pass: { hk: $hk, jp: $jp, us: $us, local: $local } }
  ' | write_meta

  echo "Installing systemd service..."
  priv tee /etc/systemd/system/xray.service >/dev/null <<-EOF
	[Unit]
	Description=Xray Service (proxy-users)
	After=network.target nss-lookup.target

	[Service]
	Type=simple
	Environment=XRAY_LOCATION_ASSET=/usr/local/share/xray
	ExecStart=/usr/local/bin/xray run -config $PROXY_USERS_CONFIG
	Restart=on-failure
	RestartSec=3
	LimitNOFILE=1048576

	[Install]
	WantedBy=multi-user.target
	EOF

  priv systemctl daemon-reload
  priv systemctl enable --now xray
  echo "Xray service enabled and started."

  echo
  load_meta
  print_mihomo_snippet
  echo
  echo "Next steps:"
  echo "  1) Merge the snippet above into your mihomo config, fix the group names, restart mihomo."
  echo "  2) Add a user:   proxy-users add alice"
}
