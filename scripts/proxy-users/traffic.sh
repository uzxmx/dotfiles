usage_traffic() {
  cat <<-EOF
Usage: proxy-users traffic [name] [--reset]

Show per-user up/down traffic, queried live from Xray's stats API. Rows are
per email (name-node). Pass a name to filter to one user. Pass --reset to
zero the counters after reading.

Examples:
  proxy-users traffic
  proxy-users traffic alice
  proxy-users traffic --reset
EOF
  exit 1
}

_human() { numfmt --to=iec-i --suffix=B "${1:-0}" 2>/dev/null || echo "${1:-0}"; }

cmd_traffic() {
  need xray; need jq

  local name="" reset=""
  while [ "$#" -gt 0 ]; do
    case "$1" in
      --reset) reset="-reset" ;;
      -h) usage_traffic ;;
      -*) die "Unknown argument '$1'" ;;
      *) [ -z "$name" ] && name="$1" || die "Unexpected argument '$1'" ;;
    esac
    shift
  done

  local raw
  raw="$(xray api statsquery --server="$XRAY_API_ADDR" -pattern "user>>>" $reset 2>/dev/null)" ||
    die "Cannot reach Xray stats API at $XRAY_API_ADDR (is xray running?)"

  {
    printf 'USER\tUP\tDOWN\tTOTAL\n'
    echo "$raw" | jq -r --arg name "$name" '
      (.stat // [])
      | map({ e: (.name | split(">>>")[1]),
              d: (.name | split(">>>")[3]),
              v: (.value // 0) })
      | group_by(.e)
      | map({ e: .[0].e,
              up: (map(select(.d=="uplink").v) | add // 0),
              down: (map(select(.d=="downlink").v) | add // 0) })
      | (if $name == "" then . else map(select(.e | startswith($name + "-"))) end)
      | sort_by(.e)
      | .[] | "\(.e) \(.up) \(.down)"
    ' | while read -r email up down; do
      printf '%s\t%s\t%s\t%s\n' "$email" "$(_human "$up")" "$(_human "$down")" "$(_human "$((up + down))")"
    done
  } | column -t -s $'\t'
}
