usage_log() {
  cat <<-EOF
Usage: proxy-users log <on|off|status|tail>

Control Xray connection logging.
  on [level]  raise log level to 'info' (or 'debug') so connection/access
              logs appear, then restart Xray. Default level: info.
  off         set log level back to 'warning' (quiet) and restart Xray.
  status      show the current log level.
  tail        follow Xray's live log (journalctl). Connection lines like
              'accepted tcp:host:443 [vless-in -> n-hk] email: alice-hk'
              appear only when level is info/debug.

Examples:
  proxy-users log on
  proxy-users log tail
  proxy-users log off
EOF
  exit 1
}

cmd_log() {
  local action="$1"
  case "$action" in
    on)
      need jq; require_config
      local level="${2:-info}"
      case "$level" in info | debug) ;; *) die "level must be 'info' or 'debug'" ;; esac
      read_config | jq --arg l "$level" '.log.loglevel = $l' | write_config
      reload_xray
      echo "Xray log level set to '$level'. Follow with: proxy-users log tail"
      ;;
    off)
      need jq; require_config
      read_config | jq '.log.loglevel = "warning"' | write_config
      reload_xray
      echo "Xray log level set to 'warning' (quiet)."
      ;;
    status)
      need jq; require_config
      echo "current log level: $(read_config | jq -r '.log.loglevel')"
      ;;
    tail)
      need jq; require_config
      command -v journalctl &>/dev/null || die "journalctl not found"
      local lvl; lvl="$(read_config | jq -r '.log.loglevel')"
      if [ "$lvl" = "warning" ] || [ "$lvl" = "error" ]; then
        echo "(note: level is '$lvl'; run 'proxy-users log on' to see connection logs)" >&2
      fi
      priv journalctl -u xray -n 50 -f
      ;;
    -h | "")
      usage_log
      ;;
    *)
      usage_log
      ;;
  esac
}
