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
EOF
  exit 1
}

cmd_dns() {
  local cmd="$1"
  shift || true
  [ -z "$cmd" ] && usage_dns

  case "$cmd" in
    l | list | r | records | g | get | a | add)
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
  jq -r '.DomainRecords.Record[] | "RR: \(.RR).\(.DomainName)\tType: \(.Type)\tValue: \(.Value)"' | column -t -s $'\t'
}

cmd_dns_records() {
  local domain="$1"
  [ -z "$domain" ] && echo 'A domain is required.' && exit 1
  process_profile_opts
  run_cli process_dns_records_output alidns DescribeDomainRecords --DomainName "$domain" --
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
        usage_dns_add
        ;;
      *)
        domain="$1"
        ;;
    esac
    shift
  done

  [ -z "$domain" ] && echo 'A domain is required.' && exit 1

  local rr="$(parse_rr "$domain")"
  domain="$(parse_primary_domain "$domain")"
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

cmd_dns_add() {
  local record_type record_value
  local domain
  while [ "$#" -gt 0 ]; do
    case "$1" in
      -t)
        shift
        record_type="$(echo "$1" | tr a-z A-Z)"
        ;;
      -v)
        shift
        record_value="$1"
        ;;
      -*)
        usage_dns_add
        ;;
      *)
        domain="$1"
        ;;
    esac
    shift
  done

  [ -z "$domain" ] && echo 'A domain is required.' && exit 1
  [ -z "$record_type" ] && echo 'A record type is required.' && exit 1
  [ -z "$record_value" ] && echo 'A record value is required.' && exit 1

  local result="$(cmd_dns_get "$domain" -t "$record_type")"
  if [ -n "$result" ]; then
    echo -e "Current record details are:\n$result"
    source "$dotfiles_dir/scripts/lib/prompt.sh"
    [ "$(yesno "Still want to update?(y/N)" "no")" = "no" ] && echo Cancelled && exit 1
  fi

  local rr="$(parse_rr "$domain")"
  domain="$(parse_primary_domain "$domain")"

  process_profile_opts
  run_cli '' alidns AddDomainRecord --DomainName "$domain" --RR "${rr:-@}" --Type "$record_type" --Value "$record_value"
}
