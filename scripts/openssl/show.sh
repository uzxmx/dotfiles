source "$(dirname "$BASH_SOURCE")/../lib/utils.sh"

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

  local header="$(grep "^-----BEGIN" "$pem_file" | sed "s/^-----BEGIN\(.*\)-----/\1/" | head -1 | "$DOTFILES_DIR/bin/trim")"
  case "$header" in
    # Currently only support RSA public key.
    "PUBLIC KEY" | "RSA PUBLIC KEY")
      "$OPENSSL_CMD" rsa -in "$pem_file" -pubin -text -noout
      ;;
    "PRIVATE KEY")
      warn "openssl doesn't support 'PRIVATE KEY' header by default. Will assume it as RSA PRIVATE KEY"
      sed "s/PRIVATE KEY/RSA PRIVATE KEY/" "$pem_file" | "$OPENSSL_CMD" rsa -text -noout
      ;;
    "RSA PRIVATE KEY")
      "$OPENSSL_CMD" rsa -in "$pem_file" -text -noout
      ;;
    "CERTIFICATE REQUEST")
      # Display the name in oneline form on a terminal supporting UTF8.
      "$OPENSSL_CMD" req -in "$pem_file" -text -noout -nameopt oneline,-esc_msb
      ;;
    "CERTIFICATE")
      # Display the name in oneline form on a terminal supporting UTF8.
      "$OPENSSL_CMD" x509 -in "$pem_file" -text -noout -nameopt oneline,-esc_msb
      ;;
    *)
      echo "Cannot infer the type from the header. Please check if the file contains a supported '-----BEGIN' header."
      ;;
  esac
}
alias_cmd s show
