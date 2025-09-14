source "$(dirname "$BASH_SOURCE")/common.sh"

usage_cert() {
  cat <<-EOF
Usage: qiniu cert

Manage SSL certificates.

Subcommands:
  l, list   - list certs
  u, upload - upload cert
  d, delete - delete cert
EOF
  exit 1
}

cmd_cert() {
  local cmd="$1"
  shift || true
  [ -z "$cmd" ] && usage_cert

  case "$cmd" in
    l | list | u | upload | d | delete)
      case "$cmd" in
        l)
          cmd="list"
          ;;
        u)
          cmd="upload"
          ;;
        d)
          cmd="delete"
          ;;
      esac
      case "$1" in
        -h)
          type "usage_cert_$cmd" &>/dev/null && "usage_cert_$cmd"
          ;;
      esac
      "cmd_cert_$cmd" "$@"
      ;;
    *)
      usage_cert
      ;;
  esac
}
alias_cmd c cert

usage_cert_list() {
  cat <<-EOF
Usage: qiniu cert list
EOF
  exit 1
}

cmd_cert_list() {
  local query="marker=&limit=100"
  get_req /sslcert "$query" "" api.qiniu.com | jq -r '.certs[] | "ID: \(.certid)\tName: \(.name)\tExpireAt: \(.not_after | strflocaltime("%Y-%m-%d %H:%M:%S"))"' | column -t -s $'\t'
}

usage_cert_upload() {
  cat <<-EOF
Usage: qiniu cert upload

Options:
  -n <name> name
  --cert-file <file>
  --key-file <file>
EOF
  exit 1
}

cmd_cert_upload() {
  local name cert_file key_file
  while [ "$#" -gt 0 ]; do
    case "$1" in
      -n)
        shift
        name="$1"
        ;;
      --cert-file)
        shift
        cert_file="$1"
        ;;
      --key-file)
        shift
        key_file="$1"
        ;;
      *)
        usage_cert_upload
        ;;
    esac
    shift
  done

  local cert="$(awk 'NF {sub(/\r/, ""); printf "%s\\n",$0;}' "$cert_file")"
  local key="$(awk 'NF {sub(/\r/, ""); printf "%s\\n",$0;}' "$key_file")"

  local body="{
  \"name\": \"$name\",
  \"pri\": \"$key\",
  \"ca\": \"$cert\"
}"

  post_req /sslcert "" "$body" api.qiniu.com "application/json"
}

usage_cert_delete() {
  cat <<-EOF
Usage: qiniu cert delete <cert-id>
EOF
  exit 1
}

cmd_cert_delete() {
  local cert_id
  while [ "$#" -gt 0 ]; do
    case "$1" in
      -*)
        usage_cert_upload
        ;;
      *)
        if [ -z "$cert" ]; then
          cert_id="$1"
        else
          abort "Only one cert ID should be specified"
        fi
        ;;
    esac
    shift
  done

  [ -z "$cert_id" ] && abort "A cert ID is required"

  _req DELETE "/sslcert/$cert_id" "" "" api.qiniu.com
}
