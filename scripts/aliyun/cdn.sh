source "$aliyun_dir/common.sh"

# TODO Refresh or prefetch for CDN resources. See:
# * https://help.aliyun.com/document_detail/27140.htm#section-81a-rm1-sis
# * https://help.aliyun.com/document_detail/151829.htm?spm=a2c4g.11186623.0.0.4bd52288nsx2FZ#topic-2404622
usage_cdn() {
  cat <<-EOF
Usage: aliyun cdn

Manage cdn.

Subcommands:
  l, list      - list cdn domains
  g, get       - get cdn information for a domain
  v, verify    - verify domain owner
  a, add       - add cdn domain
  c, configure - configure a cdn domain
  d, delete    - delete cdn domain
EOF
  exit 1
}

cmd_cdn() {
  local cmd="$1"
  shift || true
  [ -z "$cmd" ] && usage_cdn

  case "$cmd" in
    l | list | g | get | v | verify | a | add | d | delete | c | configure)
      case "$cmd" in
        l)
          cmd="list"
          ;;
        g)
          cmd="get"
          ;;
        v)
          cmd="verify"
          ;;
        a)
          cmd="add"
          ;;
        c)
          cmd="configure"
          ;;
        d)
          cmd="delete"
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

usage_cdn_list() {
  cat <<-EOF
Usage: aliyun cdn list

List cdn domains.
EOF
  exit 1
}

process_cdn_list_output() {
  jq -r '.Domains.PageData[] | "Name: \(.DomainName)\tCoverage: \(.Coverage)\tStatus: \(.DomainStatus)\tCdnType: \(.CdnType)\tSources: \(.Sources.Source[] | "\(.Type): \(.Content):\(.Port)")"' | column -t -s $'\t'
}

select_cdn_domain() {
  run_cli '' cdn DescribeUserDomains | jq -r '.Domains.PageData[] | .DomainName' | fzf --prompt "Select a CDN domain> "
}

cmd_cdn_list() {
  process_profile_opts
  run_cli process_cdn_list_output cdn DescribeUserDomains
}

usage_cdn_get() {
  cat <<-EOF
Usage: aliyun cdn get <domain-name>

Get cdn information for a domain.

Options:
  -c Show certificate
  --no-cname-check Do not check whether CNAME is configured, it checks by default
EOF
  exit 1
}

cmd_cdn_get() {
  local domain show_certificate no_cname_check
  while [ "$#" -gt 0 ]; do
    case "$1" in
      -c)
        show_certificate="1"
        ;;
      --no-cname-check)
        no_cname_check="1"
        ;;
      -*)
        usage_cdn_get
        ;;
      *)
        domain="$1"
        ;;
    esac
    shift
  done

  process_profile_opts
  if [ -z "$domain" ]; then
    domain="$(select_cdn_domain)"
  fi

  local result
  result="$(run_cli '' cdn DescribeCdnDomainDetail --DomainName "$domain")"
  echo "$result"

  if [ "$show_certificate" = "1" ]; then
    _get_cdn_certificate "$domain"
  fi

  if [ ! "$no_cname_check" = "1" ]; then
    if _is_cname_configured "$domain" "$(echo "$result" | jq -r '.GetDomainDetailModel.Cname')"; then
      echo "CNAME has been configured successfully."
    else
      echo "CNAME has not been configured."
    fi
  fi
}

_add_cname_for_cdn_domain() {
  cmd_dns_add "$1" -t CNAME  -v "$2"
}

usage_cdn_verify() {
  cat <<-EOF
Usage: aliyun cdn verify <domain-name>

Verify domain owner.
EOF
  exit 1
}

cmd_cdn_verify() {
  local domain="$1"
  [ -z "$domain" ] && echo 'A domain is required.' && exit 1

  process_profile_opts
  run_cli '' cdn VerifyDomainOwner --DomainName "$domain" --VerifyType dnsCheck
}

verify_cdn_domain() {
  local domain="$1"
  domain="$(parse_primary_domain "$domain")"

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

usage_cdn_add() {
  cat <<-EOF
Usage: aliyun cdn add <domain-name>

Add CDN domain.

For more information, please visit
https://help.aliyun.com/document_detail/91176.html?spm=a2c4g.11186623.6.845.2da74b879LKg6J

Options:
  -t <cdn_type> type can be web, download or video, default to web
  -s <source> the format is <host>[:<port>], host can be a domain or IP
              address, when port is omitted, default to 80
EOF
  exit 1
}

cmd_cdn_add() {
  local cdn_type="web"
  local domain
  local sources
  local source_host
  while [ "$#" -gt 0 ]; do
    case "$1" in
      -t)
        shift
        cdn_type="$1"
        ;;
      -s)
        shift
        local host="$(echo "$1" | awk -F: '{print $1}')"
        local port="$(echo "$1" | awk -F: '{print $2}')"
        local host_type
        if [[ "$host" =~ ^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}$ ]]; then
          host_type="ipaddr"
        else
          host_type="domain"
          source_host="$host"
        fi
        local source="$(printf '{"content":"%s","type":"%s","port":%s,"priority":"20","weight":"15"}' "$host" "$host_type" "${port:-80}")"

        if [ -z "$sources" ]; then
          sources="$source"
        else
          sources="$sources,$source"
        fi
        ;;
      -*)
        usage_cdn_add
        ;;
      *)
        domain="$1"
        ;;
    esac
    shift
  done

  [ -z "$domain" ] && echo "A domain is required." && exit 1
  [ -z "$sources" ] && echo 'At least a source should be specified' && exit 1

  process_profile_opts
  verify_cdn_domain "$domain"
  run_cli '' cdn AddCdnDomain --CdnType "$cdn_type" --DomainName "$domain" --Sources "[$sources]"

  if [ -n "$source_host" ]; then
    cmd_cdn_configure "$domain" --source-host "$source_host"
  else
    cmd_cdn_configure "$domain"
  fi
}

_get_cdn_domain_config() {
  # For a list of available function names, please visit
  # https://help.aliyun.com/document_detail/90924.htm?spm=a2c4g.11186623.2.8.669475e8yh1eHd
  run_cli '' cdn DescribeCdnDomainConfigs --DomainName "$1" --FunctionNames "$2" | jq -r '.DomainConfigs.DomainConfig[] | .FunctionArgs.FunctionArg[] | .ArgValue'
}

usage_cdn_delete() {
  cat <<-EOF
Usage: aliyun cdn delete <domain-name>

Delete cdn domain.
EOF
  exit 1
}

cmd_cdn_delete() {
  local domain="$1"

  process_profile_opts
  if [ -z "$domain" ]; then
    domain="$(select_cdn_domain)"
  fi

  source "$DOTFILES_DIR/scripts/lib/prompt.sh"
  [ "$(yesno "Confirm to delete CDN $domain? (y/N)" "no")" = "no" ] && echo Cancelled && exit 1

  run_cli '' cdn DeleteCdnDomain --DomainName "$domain"
}

_is_cname_configured() {
  local domain="$1"
  local cname="$2"
  source "$aliyun_dir/dns.sh"
  local value="$(cmd_dns_get -t CNAME "$domain" | jq -r '.Value')"
  [ "$value" = "$cname" ]
}

_get_cdn_certificate() {
  run_cli '' cdn DescribeDomainCertificateInfo --DomainName "$1"
}

_is_cdn_certificate_enabled() {
  [ "$(_get_cdn_certificate "$1" | jq -r '.CertInfos.CertInfo[] | .ServerCertificateStatus')" = "on" ]
}

usage_cdn_configure() {
  cat <<-EOF
Usage: aliyun cdn configure <domain-name>

Configure a cdn domain.

Options:
  --source-host <host> Host header when visiting the origin
EOF
  exit 1
}

cmd_cdn_configure() {
  local domain source_host
  while [ "$#" -gt 0 ]; do
    case "$1" in
      --source-host)
        shift
        source_host="$1"
        ;;
      -*)
        usage_cdn_configure
        ;;
      *)
        domain="$1"
        ;;
    esac
    shift
  done

  process_profile_opts
  if [ -z "$domain" ]; then
    domain="$(select_cdn_domain)"
  fi

  local cname
  while true; do
    cname="$(cmd_cdn_get --no-cname-check "$domain" | jq -r '.GetDomainDetailModel.Cname')"
    if [ -n "$cname" ]; then
      break
    fi
    echo 'CNAME is not present yet. Sleep 2s and try...'
    sleep 2
  done

  if ! _is_cname_configured "$domain" "$cname"; then
    _add_cname_for_cdn_domain "$domain" "$cname"
    sleep 1
  fi

  if [ -n "$source_host" -a "$source_host" != "$(_get_cdn_domain_config "$domain" set_req_host_header)" ]; then
    echo "Config CDN: set_req_host_header"
    # See https://help.aliyun.com/document_detail/388460.html
    run_cli '' cdn BatchSetCdnDomainConfig --DomainNames "$domain" --Functions "[{ \"functionArgs\": [{ \"argName\": \"domain_name\", \"argValue\": \"$source_host\" }], \"functionName\": \"set_req_host_header\" }]"
  fi

  if ! _is_cdn_certificate_enabled "$domain"; then
    echo "Config CDN: SetDomainServerCertificate"
    run_cli '' cdn SetDomainServerCertificate --DomainName "$domain" --ServerCertificateStatus on --CertType free
  fi
}
