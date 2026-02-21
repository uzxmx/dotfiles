usage_upload_cert() {
  cat <<-EOF
Usage: acme upload_cert -n <name> <user@ip>...

Check and upload certificate to host.

Options:
  -n <name>
  -h <server_host> server host to check if certificate should be uploaded
EOF
  exit 1
}

cmd_upload_cert() {
  local name
  local -a hosts
  while [ "$#" -gt 0 ]; do
    case "$1" in
      -n)
        shift
        name="$1"
        ;;
      -h)
        shift
        server_host="$1"
        ;;
      -*)
        usage_upload_cert
        ;;
      *)
        hosts+=("$1")
        ;;
    esac
    shift
  done

  [ -z "$name" ] && usage_upload_cert
  [ "${#hosts}" -eq 0 ] && abort "At least one ssh host should be specified"

  local cert_file="/etc/certs/$name/cert.pem"

  if [ -n "$server_host" ]; then
    local expire_date current_date
    expire_date="$(openssl x509 -enddate -noout -in "$cert_file" | cut -d = -f 2- | date +%Y%m%d -f -)"
    current_date="$(echo | openssl s_client -connect $server_host:443 2>/dev/null | openssl x509 -noout -enddate | cut -d = -f 2- | date +%Y%m%d -f -)"

    if [[ "$current_date" -ge "$expire_date" ]]; then
      echo "No need to upload certificate"
      exit
    fi
  fi

  echo "Upload certificate..."

  sudo cp "$cert_file" "/tmp/$name-cert.pem"
  sudo cp "/etc/certs/$name/key.pem" "/tmp/$name-key.pem"
  sudo chown "$(whoami)" "/tmp/$name-cert.pem" "/tmp/$name-key.pem"

  for host in "${hosts[@]}"; do
    scp "/tmp/$name-cert.pem" $host:/etc/certs/$name/cert.pem
    scp "/tmp/$name-key.pem" $host:/etc/certs/$name/key.pem
    ssh $host sudo systemctl restart nginx
  done

  echo Done
}
