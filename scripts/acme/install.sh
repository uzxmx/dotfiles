usage_install() {
  cat <<-EOF
Usage: acme install [domain]

Install issued certificate for a domain. It will ask you to select one by fzf if no
domain is specified.

Options:
  -t <dir> Directory to copy the key file and fullchain file to after issue/renew

  --cert-file <file>      Path to copy the cert file to after issue/renew
  --key-file <file>       Path to copy the key file to after issue/renew
  --ca-file <file>        Path to copy the intermediate cert file to after issue/renew
  --fullchain-file <file> Path to copy the fullchain cert file to after issue/renew

  -r <reload_command> Command to execute after issue/renew to reload the server

Examples:
  acme install example.com -r "docker restart nginx_nginx_1"
EOF
  exit 1
}

cmd_install() {
  local cert
  local -a opts
  local arg_name
  local target_dir
  while [ "$#" -gt 0 ]; do
    case "$1" in
      -t)
        shift
        target_dir="$1"
        ;;
      --cert-file | --key-file | --ca-file | --fullchain-file)
        arg_name="$1"
        shift
        opts+=("$arg_name" "$1")
        ;;
      -r)
        shift
        opts+=(--reloadcmd "$1")
        ;;
      -*)
        usage_install
        ;;
      *)
        cert="$1"
        ;;
    esac
    shift
  done

  source "$acme_dir/common.sh"

  if [ -z "$cert" ]; then
    cert="$(select_certificate)"
  fi

  if [ -z "$target_dir" ]; then
    target_dir="/etc/certs/$cert"
    echo "Using default target dir: $target_dir"
    if [ ! -e /etc/certs ]; then
      sudo mkdir -p /etc/certs && sudo chown "$(whoami):$(id -Gn | awk '{print $1}')" /etc/certs
    fi
  fi
  [ -e "$target_dir" ] || mkdir "$target_dir"
  opts+=(--key-file "$target_dir/key.pem" --fullchain-file "$target_dir/cert.pem")

  run_acme --install-cert -d "$cert" "${opts[@]}"
}
