source "$aliyun_dir/common.sh"

usage_cdn() {
  cat <<-EOF
Usage: aliyun cdn

Manage CDN.

Subcommands:
  g, get    - get cdn information for a domain
  v, verify - verify domain owner
EOF
  exit 1
}

cmd_cdn() {
  local cmd="$1"
  shift || true
  [ -z "$cmd" ] && usage_cdn

  case "$cmd" in
    g | get | v | verify)
      case "$cmd" in
        g)
          cmd="get"
          ;;
        v)
          cmd="verify"
          ;;
      esac
      case "$1" in
        -h)
          type "usage_cdn_$cmd" &>/dev/null && "usage_cdn_$cmd"
          ;;
      esac
      "cmd_cdn_$cmd" "$@"
      ;;
    *)
      usage_cdn
      ;;
  esac
}
alias_cmd c cdn

usage_cdn_get() {
  cat <<-EOF
Usage: aliyun cdn get <domain-name>

Get cdn information for a domain.
EOF
  exit 1
}

cmd_cdn_get() {
  local domain="$1"
  [ -z "$domain" ] && echo 'A domain is required.' && exit 1

  process_profile_opts
  run_cli '' cdn DescribeCdnDomainDetail --DomainName "$domain"
}

cmd_cdn_verify() {
  local domain="$1"
  [ -z "$domain" ] && echo 'A domain is required.' && exit 1

  process_profile_opts
  run_cli '' cdn VerifyDomainOwner --DomainName "$domain" --VerifyType dnsCheck
}

verify_cdn_domain() {
  local domain="$1"
  domain=$(parse_primary_domain "$domain")

  if run_cli '' cdn VerifyDomainOwner --DomainName "$domain" --VerifyType dnsCheck &>/dev/null; then
    echo 'Verification succeeded.'
  else
    echo 'Verification failed. Start to add DNS record for verification.'

    local verify_content
    verify_content="$(run_cli '' cdn DescribeVerifyContent --DomainName "$domain" | jq -r '.Content')"

    source "$aliyun_dir/dns.sh"
    cmd_dns_add "verification.$domain" -t TXT -v "$verify_content" &>/dev/null || true

    while true; do
      echo 'Sleep 2s and verify...'
      sleep 2
      if run_cli '' cdn VerifyDomainOwner --DomainName "$domain" --VerifyType dnsCheck &>/dev/null; then
        break
      else
        echo 'Verification failed.'
      fi
    done
  fi
}
