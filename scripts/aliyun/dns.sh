source "$aliyun_dir/common.sh"

usage_dns() {
  cat <<-EOF
Usage: aliyun dns

Manage DNS.

Subcommands:
  l, list    - list domains
  r, records - list DNS records for a domain
EOF
  exit 1
}

cmd_dns() {
  local cmd="$1"
  shift || true
  [ -z "$cmd" ] && usage_dns

  case "$cmd" in
    l | list | r | records)
      case "$cmd" in
        l)
          cmd="list"
          ;;
        r)
          cmd="records"
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
  run_cli process_dns_records_output alidns DescribeDomainRecords --DomainName "$domain"
}
