# Also see https://prometheus.io/docs/alerting/latest/clients/
usage_alert() {
  cat <<-EOF
Usage: alertmanager alert

Send an alert for test.

Options:
  -n <alert-name> Alert name
EOF
  exit 1
}

generate_post_data() {
  cat <<EOF
[{
  "status": "$1",
  "labels": {
    "alertname": "$2",
    "service": "my-service",
    "severity":"warning",
    "instance": "foo.example.com",
    "namespace": "foo",
    "foo": "bar"
  },
  "annotations": {
    "summary": "High latency is high!"
  },
  "generatorURL": "http://example.com/foo"
  $3
  $4
}]
EOF
}

get_current_time() {
  if is_mac; then
    date -u "+%FT%TZ"
  else
    date --rfc-3339=seconds | sed "s/ /T/"
  fi
}

cmd_alert() {
  local alert_name="test-alert"
  while [ "$#" -gt 0 ]; do
    case "$1" in
      -n)
        shift
        alert_name="$1"
        ;;
      *)
        usage_alert
        ;;
    esac
    shift
  done

  local start_at=", \"startsAt\": \"$(get_current_time)\""
  local data="$(generate_post_data firing "$alert_name" "$start_at")"
  post_req /api/v1/alerts -d "$data"

  echo -e "\nPress enter to resolve alert"
  read

  local end_at=", \"endsAt\": \"$(get_current_time)\""
  data="$(generate_post_data resolved "$alert_name" "$start_at" "$end_at")"
  post_req /api/v1/alerts -d "$data"
}
