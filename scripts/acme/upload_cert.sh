usage_upload_cert() {
  cat <<-EOF
Usage: acme upload_cert <name> <host>...

Upload certificate to host.

Options:
  -n <name>
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
  [ "${#hosts}" -eq 0 ] && abort "At least one host should be specified"

  sudo cp "/etc/certs/$name/cert.pem" "/tmp/$name-cert.pem"
  sudo cp "/etc/certs/$name/key.pem" "/tmp/$name-key.pem"
  sudo chown "$(whoami)" "/tmp/$name-cert.pem" "/tmp/$name-key.pem"

  for host in "${hosts[@]}"; do
    scp "/tmp/$name-cert.pem" $host:/etc/certs/$name/cert.pem
    scp "/tmp/$name-key.pem" $host:/etc/certs/$name/key.pem
    ssh $host sudo systemctl restart nginx
  done
}
