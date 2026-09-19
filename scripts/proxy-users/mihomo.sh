usage_mihomo() {
  cat <<-EOF
Usage: proxy-users mihomo

Print the config snippet to merge into your mihomo config: the per-node
socks authentication users (passwords match Xray's outbounds) and the
IN-USER routing rules. Replace the placeholder group names (HK/JP/US) with
your real proxy-group names, then restart mihomo.
EOF
  exit 1
}

cmd_mihomo() {
  need jq
  require_meta
  [ "$1" = "-h" ] && usage_mihomo

  load_meta
  print_mihomo_snippet
}
