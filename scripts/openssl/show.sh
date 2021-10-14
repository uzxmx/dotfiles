usage_show() {
  cat <<-EOF
Usage: openssl show <PEM-file>

Show the content of a PEM file. The PEM must contain a '-----BEGIN' header,
otherwise it cannot infer the type.

Supported types include:
  * certificate
  * RSA public/private key
  * certificate request
EOF
  exit 1
}

cmd_show() {
  local pem_file="$1"
  [ ! -f "$pem_file" ] && echo 'A PEM file is required.' && exit 1

  local header="$(grep "^-----BEGIN" "$pem_file" | sed "s/^-----BEGIN\(.*\)-----/\1/" | head -1 | "$dotfiles_dir/bin/trim")"
  case "$header" in
    # Currently only support RSA public key.
    "PUBLIC KEY" | "RSA PUBLIC KEY")
      openssl rsa -in "$pem_file" -pubin -text -noout
      ;;
    "RSA PRIVATE KEY")
      openssl rsa -in "$pem_file" -text -noout
      ;;
    "CERTIFICATE REQUEST")
      openssl req -in "$pem_file" -text -noout
      ;;
    "CERTIFICATE")
      openssl x509 -in "$pem_file" -text -noout
      ;;
    *)
      echo "Cannot infer the type from the header. Please check if the file contains a supported '-----BEGIN' header."
      ;;
  esac
}
alias_cmd s show
