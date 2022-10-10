usage_issue() {
  cat <<-EOF
Usage: acme issue <domain>...

Issue a certificate for domains.

When you get a certificate, it validates that you control the domain
names in that certificate using 'challenges' as defined by the ACME standard.

There are challenge types such as 'HTTP-01 challenge', 'DNS-01 challenge'.
For more info, please visit 'https://letsencrypt.org/docs/challenge-types/'.

When using 'dns_ali', you may also need to export 'Ali_Key' and 'Ali_Secret' environment variables.

When timeout happens for curl, you may use HTTP proxy.

Options:
  -d <dns_provider> The DNS provider to use for DNS-01 challenge. Supported values include 'dns_ali'.
                    See 'https://github.com/acmesh-official/acme.sh/wiki/dnsapi' for a list of providers

Examples:
  # Issue a certificate for one or more domains by aliyun DNS.
  acme issue -d dns_ali example.com
  acme issue -d dns_ali example.com www.example.com

  # Issue a certificate for both normal and wildcard domains by aliyun DNS.
  acme issue -d dns_ali example.com "*.example.com"
EOF
  exit 1
}

check_acme_env() {
  cat "$ACME_HOME/account.conf" | grep -E "^$1=.+" &>/dev/null
}

cmd_issue() {
  local -a domain_opts
  while [ "$#" -gt 0 ]; do
    case "$1" in
      -d)
        shift
        dns_provider="$1"
        ;;
      -*)
        usage_issue
        ;;
      *)
        domain_opts+=(-d "$1")
        ;;
    esac
    shift
  done

  case "$dns_provider" in
    dns_ali)
      if [ -z "$Ali_Key" -o -z "$Ali_Secret" ]; then
        if ! check_acme_env SAVED_Ali_Key || ! check_acme_env SAVED_Ali_Secret; then
          echo "You must export Ali_Key and Ali_Secret."
          exit 1
        fi
      fi
      ;;
  esac

  [ -z "$dns_provider" ] && usage_issue

  [ "${#domain_opts[@]}" -eq 0 ] && usage_issue

  run_acme --issue --dns "$dns_provider" --server letsencrypt "${domain_opts[@]}"
}
alias_cmd i issue
