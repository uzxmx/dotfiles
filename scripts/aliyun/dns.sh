source "$aliyun_dir/common.sh"

usage_dns() {
  cat <<-EOF
Usage: aliyun dns

Manage DNS.

For more information, please visit
https://help.aliyun.com/product/29697.html

Subcommands:
  l, list    - list domains
  r, records - list DNS records for a domain
  g, get     - get DNS record details
  a, add     - add DNS record for a domain
  u, update  - update DNS record for a domain
  d, delete  - delete DNS record for a domain
EOF
  exit 1
}

cmd_dns() {
  local cmd="$1"
  shift || true
  [ -z "$cmd" ] && usage_dns

  case "$cmd" in
    l | list | r | records | g | get | a | add | u | update | d | delete)
      case "$cmd" in
        l)
          cmd="list"
          ;;
        r)
          cmd="records"
          ;;
        g)
          cmd="get"
          ;;
        a)
          cmd="add"
          ;;
        u)
          cmd="update"
          ;;
        d)
          cmd="delete"
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

process_dns_list_output() {
  jq -r '.Domains.Domain[] | "Name: \(.DomainName)\tDNSServers: \(.DnsServers[])\tCreated at: \(.CreateTime)"' | column -t -s $'\t'
}

select_dns_domain() {
  run_cli '' alidns DescribeDomains | jq -r '.Domains.Domain[] | .DomainName' | fzf --prompt "Select a domain> " -1
}

cmd_dns_list() {
  process_profile_opts
  run_cli process_dns_list_output alidns DescribeDomains
}

usage_dns_records() {
  cat <<-EOF
Usage: aliyun dns records <domain-name>

List DNS records for a domain.
EOF
  exit 1
}

process_dns_records_output() {
  jq -r '.DomainRecords.Record[] | "RecordId: \(.RecordId)\tRR: \(.RR).\(.DomainName)\tType: \(.Type)\tValue: \(.Value)"' | column -t -s $'\t'
}

cmd_dns_records() {
  local domain="$1"

  process_profile_opts
  if [ -z "$domain" ]; then
    domain="$(select_dns_domain)"
  fi

  run_cli process_dns_records_output alidns DescribeDomainRecords --DomainName "$domain"
}

usage_dns_get() {
  cat <<-EOF
Usage: aliyun dns get <domain-name>

Get a DNS record details.

Options:
  -t <type> record type, e.g. A, CNAME, TXT
EOF
  exit 1
}

cmd_dns_get() {
  local -a opts
  local domain
  while [ "$#" -gt 0 ]; do
    case "$1" in
      -t)
        shift
        opts+=(--TypeKeyWord "$(echo "$1" | tr a-z A-Z)")
        ;;
      -*)
        usage_dns_get
        ;;
      *)
        domain="$1"
        ;;
    esac
    shift
  done

  [ -z "$domain" ] && echo 'A domain is required.' && exit 1

  eval "$(_common_scripts_for_parsing_rr_and_domain)"
  process_profile_opts

  run_cli '' alidns DescribeDomainRecords --DomainName "$domain" --RRKeyWord "${rr:-@}" "${opts[@]}" | jq -r ".DomainRecords.Record[] | select(.RR == \"$rr\")"
}

usage_dns_add() {
  cat <<-EOF
Usage: aliyun dns add <domain-name>

Add DNS record for a domain. RR will be parsed from the domain name.

Options:
  -t <type> record type, e.g. A, CNAME, TXT
  -v <value> record value
EOF
  exit 1
}

_common_scripts_for_parsing_rr_and_domain() {
  cat <<'EOF'
  local rr="$(parse_rr "$domain")"
  rr="${rr:-@}"
  domain="$(parse_primary_domain "$domain")"
EOF
}

_common_scripts_for_dns_record() {
  local _usage="$1"
  local check="${2:-1}"
  local other_opts_process_scripts
  if [ -z "$3" ]; then
    other_opts_process_scripts="$_usage"
  else
    other_opts_process_scripts="$3"
  fi
  cat <<EOF
  local record_type record_value
  local domain
  while [ "\$#" -gt 0 ]; do
    case "\$1" in
      -t)
        shift
        record_type="\$(echo "\$1" | tr a-z A-Z)"
        ;;
      -v)
        shift
        record_value="\$1"
        ;;
      -*)
        $other_opts_process_scripts
        ;;
      *)
        domain="\$1"
        ;;
    esac
    shift
  done

  [ "$check" = "1" -a -z "\$domain" ] && echo 'A domain is required.' && exit 1
  [ "$check" = "1" -a -z "\$record_type" ] && echo 'A record type is required.' && exit 1
  [ "$check" = "1" -a -z "\$record_value" ] && echo 'A record value is required.' && exit 1
  true
EOF
}

cmd_dns_add() {
  eval "$(_common_scripts_for_dns_record usage_dns_add)"

  local result="$(cmd_dns_get "$domain" -t "$record_type")"
  if [ -n "$result" ]; then
    echo -e "Current record details are:\n$result"
    source "$dotfiles_dir/scripts/lib/prompt.sh"
    [ "$(yesno "Still want to update?(y/N)" "no")" = "no" ] && echo Cancelled && exit 1
  fi

  eval "$(_common_scripts_for_parsing_rr_and_domain)"
  process_profile_opts

  echo "Primary domain: $domain, sub domain: $rr, DNS record type: $record_type"
  run_cli '' alidns AddDomainRecord --DomainName "$domain" --RR "$rr" --Type "$record_type" --Value "$record_value"
}

usage_dns_update() {
  cat <<-EOF
Usage: aliyun dns update <domain-name>

Update DNS record for a domain. RR will be parsed from the domain name.

Options:
  -i <record-id>
  -t <type> record type, e.g. A, CNAME, TXT
  -v <value> record value
EOF
  exit 1
}

cmd_dns_update() {
  local record_id
  local other_opts_process_scripts="
case "\$1" in
  -i)
    shift
    record_id="\$1"
    ;;
  *)
    usage_dns_update
esac
"
  eval "$(_common_scripts_for_dns_record usage_dns_update 1 "$other_opts_process_scripts")"

  if [ -z "$record_id" ]; then
    record_id="$(cmd_dns_get "$domain" -t "$record_type" | jq -r ".RecordId")"
  fi

  if [ -z "$record_id" ]; then
    echo "DNS record was not found. Configuring it directly..."
    cmd_dns_add "$domain" -t "$record_type" -v "$record_value"
  else
    eval "$(_common_scripts_for_parsing_rr_and_domain)"
    process_profile_opts
    run_cli '' alidns UpdateDomainRecord --RecordId "$record_id" --RR "$rr" --Type "$record_type" --Value "$record_value"
  fi
}

usage_dns_delete() {
  cat <<-EOF
Usage: aliyun dns delete [domain-name]

Delete DNS record for a domain.

Options:
  -i <record-id>
  -t <type> record type, e.g. A, CNAME, TXT
  -f delete without confirmation
EOF
  exit 1
}

cmd_dns_delete() {
  local record_id no_confirm
  local other_opts_process_scripts="
case "\$1" in
  -i)
    shift
    record_id="\$1"
    ;;
  -f)
    no_confirm=1
    ;;
  *)
    usage_dns_update
esac
"
  eval "$(_common_scripts_for_dns_record usage_dns_delete 0 "$other_opts_process_scripts")"

  if [ -z "$record_id" ]; then
    record_id="$(cmd_dns_get "$domain" -t "$record_type" | jq -r ".RecordId")"
  fi

  if [ -z "$record_id" ]; then
    echo "DNS record was not found."
    exit 1
  elif [ -z "$no_confirm" ]; then
    source "$dotfiles_dir/scripts/lib/prompt.sh"
    if [ "$(yesno "Are you sure you want to delete?(y/N)" no)" = "no" ]; then
      echo Cancelled
      exit 1
    fi
  fi
  run_cli '' alidns DeleteDomainRecord --RecordId "$record_id"
}
