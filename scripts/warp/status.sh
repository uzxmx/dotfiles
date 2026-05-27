usage_status() {
  cat <<-EOF
Usage: warp status

Show WARP connection status, mode, proxy port, and exit IP.
EOF
  exit 1
}

cmd_status() {
  warp-cli status

  local settings
  settings="$(warp-cli settings 2>/dev/null)"

  local mode
  mode="$(echo "$settings" | grep -i "mode" | awk '{print $NF}')"
  [ -n "$mode" ] && echo "Mode:  $mode"

  local port
  port="$(echo "$settings" | grep -i "port" | grep -oE '[0-9]+' | head -1)"
  [ -n "$port" ] && echo "Proxy: 127.0.0.1:$port"

  local trace
  if [ -n "$port" ]; then
    trace="$(curl -s --max-time 5 -x "socks5h://127.0.0.1:$port" https://www.cloudflare.com/cdn-cgi/trace 2>/dev/null)"
  else
    trace="$(curl -s --max-time 5 https://www.cloudflare.com/cdn-cgi/trace 2>/dev/null)"
  fi

  if [ -n "$trace" ]; then
    local ip loc warp
    ip="$(echo "$trace" | grep '^ip=' | cut -d= -f2)"
    loc="$(echo "$trace" | grep '^loc=' | cut -d= -f2)"
    warp="$(echo "$trace" | grep '^warp=' | cut -d= -f2)"
    echo "IP:    $ip ($loc)"
    echo "WARP:  $warp"
  fi
}
alias_cmd s status
