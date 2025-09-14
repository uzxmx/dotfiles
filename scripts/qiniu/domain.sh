source "$(dirname "$BASH_SOURCE")/common.sh"

# https://developer.qiniu.com/fusion/4246/the-domain-name
usage_domain() {
  cat <<-EOF
Usage: qiniu domain

Manage domains.

Subcommands:
  l, list     - list domains
  i, info     - show a domain info
  update_cert - update ssl certificate
  auto_renew  - auto renew ssl certificate
  check_cert  - invoked by a cron job
EOF
  exit 1
}

cmd_domain() {
  local cmd="$1"
  shift || true
  [ -z "$cmd" ] && usage_domain

  case "$cmd" in
    l | list | i | info | update_cert | auto_renew | check_cert)
      case "$cmd" in
        l)
          cmd="list"
          ;;
        i)
          cmd="info"
          ;;
        u)
          cmd="upload"
          ;;
      esac
      case "$1" in
        -h)
          type "usage_domain_$cmd" &>/dev/null && "usage_domain_$cmd"
          ;;
      esac
      "cmd_domain_$cmd" "$@"
      ;;
    *)
      usage_domain
      ;;
  esac
}
alias_cmd d domain

usage_domain_list() {
  cat <<-EOF
Usage: qiniu domain list
EOF
  exit 1
}

cmd_domain_list() {
  get_req /domain "" "" api.qiniu.com | jq -r '.domains[] | "Name: \(.name)\tCreateAt: \(.createAt)"' | column -t -s $'\t'
}

usage_domain_info() {
  cat <<-EOF
Usage: qiniu domain info <domain>
EOF
  exit 1
}

cmd_domain_info() {
  local domain
  while [ "$#" -gt 0 ]; do
    case "$1" in
      -*)
        usage_domain_info
        ;;
      *)
        if [ -z "$domain" ]; then
          domain="$1"
        else
          abort "Only one domain should be specified"
        fi
        ;;
    esac
    shift
  done

  [ -z "$domain" ] && abort "A domain is required"

  get_req /domain/$domain "" "" api.qiniu.com
}

usage_domain_update_cert() {
  cat <<-EOF
Usage: qiniu domain update_cert <domains>...

Options:
  --cert-id <cert-id>
EOF
  exit 1
}

cmd_domain_update_cert() {
  local cert_id
  local -a domains
  while [ "$#" -gt 0 ]; do
    case "$1" in
      --cert-id)
        shift
        cert_id="$1"
        ;;
      -*)
        usage_domain_upload
        ;;
      *)
        domains+=("$1")
        ;;
    esac
    shift
  done

  [ -z "$cert_id" ] && abort "A cert ID is required"
  [ "${#domains}" -eq 0 ] && abort "At least one domain should be specified"

  local body="{
  \"certId\": \"$cert_id\"
}"

  local domain
  for domain in "${domains[@]}"; do
    echo "Update cert for domain: $domain"
    put_req "/domain/$domain/httpsconf" "" "$body" api.qiniu.com "application/json"
  done
}

usage_domain_auto_renew() {
  cat <<-EOF
Usage: qiniu domain auto_renew <domains>...

Options:
  --prefix <prefix>
  --cert-file <file>
  --key-file <file>
EOF
  exit 1
}

cmd_domain_auto_renew() {
  local prefix cert_file key_file
  local -a domains
  while [ "$#" -gt 0 ]; do
    case "$1" in
      --prefix)
        shift
        prefix="$1"
        ;;
      --cert-file)
        shift
        cert_file="$1"
        ;;
      --key-file)
        shift
        key_file="$1"
        ;;
      -*)
        usage_domain_check_cert
        ;;
      *)
        domains+=("$1")
        ;;
    esac
    shift
  done

  check_keys

  if ! check_command jq &>/dev/null; then
    abort "Please install 'jq' first"
  fi

  [ -z "$prefix" ] && abort "A prefix is required"
  [ -z "$cert_file" ] && abort "A certificate file is required"
  [ -z "$key_file" ] && abort "A key file is required"
  [ "${#domains}" -eq 0 ] && abort "At least one domain should be specified"

  local cron_dir="$DOTFILES_TARGET_DIR/opt/my_cron_jobs"
  mkdir -p "$cron_dir"
  local name="qiniu_domain_auto_renew-$prefix"
  local cron_job_file="$cron_dir/$name.sh"

  cat <<EOF >"$cron_job_file"
#!/usr/bin/env bash
#
# Generated. Do Not Edit.

sudo cp "$key_file" "/tmp/$name-key.pem"
sudo cp "$cert_file" "/tmp/$name-cert.pem"
sudo chown \$(whoami) "/tmp/$name-key.pem" "/tmp/$name-cert.pem"

export QINIU_ACCESS_KEY=$QINIU_ACCESS_KEY
export QINIU_SECRET_KEY=$QINIU_SECRET_KEY
"$DOTFILES_DIR/bin/qiniu" domain check_cert --prefix "$prefix" --key-file "/tmp/$name-key.pem" --cert-file "/tmp/$name-cert.pem" ${domains[@]} &>"/tmp/$name.log"
EOF

  chmod a+x "$cron_job_file"

  local croncmd="\"$cron_job_file\""
  ( crontab -l | grep -v -F " $croncmd" ; echo "1 2 * * * $croncmd" ) | crontab -
}

usage_domain_check_cert() {
  cat <<-EOF
Usage: qiniu domain check_cert <domains>...

Options:
  --prefix <prefix>
  --cert-file <file>
  --key-file <file>
EOF
  exit 1
}

cmd_domain_check_cert() {
  local prefix cert_file key_file
  local -a domains
  while [ "$#" -gt 0 ]; do
    case "$1" in
      --prefix)
        shift
        prefix="$1"
        ;;
      --cert-file)
        shift
        cert_file="$1"
        ;;
      --key-file)
        shift
        key_file="$1"
        ;;
      -*)
        usage_domain_check_cert
        ;;
      *)
        domains+=("$1")
        ;;
    esac
    shift
  done

  [ -z "$prefix" ] && abort "A prefix is required"
  [ -z "$cert_file" ] && abort "A certificate file is required"
  [ -z "$key_file" ] && abort "A key file is required"
  [ "${#domains}" -eq 0 ] && abort "At least one domain should be specified"

  local qiniu_cmd="$DOTFILES_DIR/bin/qiniu"

  local expire_date cert_name cert_id
  expire_date="$(openssl x509 -enddate -noout -in "$cert_file" | cut -d = -f 2- | date +%Y%m%d -f -)"
  cert_name="$prefix-$expire_date-generated"
  local result
  result="$("$qiniu_cmd" cert list | awk '{print $2, $4}' | grep " $cert_name$" || true)"
  if [ -z "$result" ]; then
    echo "Uploading certificate"
    cert_id="$("$qiniu_cmd" cert upload -n "$cert_name" --cert-file "$cert_file" --key-file "$key_file" | jq -r .certID)"
  else
    cert_id="$(echo "$result" | awk '{print $1}')"
  fi
  echo "Cert id: $cert_id"
  local domain current_cert_id
  for domain in "${domains[@]}"; do
    echo "Check domain $domain"
    current_cert_id="$("$qiniu_cmd" domain info "$domain" | jq -r .https.certId)"
    if [ "$cert_id" != "$current_cert_id" ]; then
      echo "Update certificate for domain $domain"
      "$qiniu_cmd" domain update_cert --cert-id "$cert_id" "$domain"
    else
      echo "No need to update certificate for domain $domain"
    fi
  done
}
