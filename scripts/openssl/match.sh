usage_match() {
  cat <<-EOF
Usage: openssl match

Check if a key pair matches. Support any key pairs such as RSA, ECDSA etc.

You can also specify an X.509 certificate to see if the private key matches
with the certificate.

Options:
  -priv <path-to-privkey-file>
  -pub <path-to-pubkey-file>
  -c   <path-to-x509-cert-file>
EOF
  exit 1
}

cmd_match() {
  local privkey_file pubkey_file cert_file
  while [ "$#" -gt 0 ]; do
    case "$1" in
      -priv)
        shift
        privkey_file="$1"
        ;;
      -pub)
        shift
        pubkey_file="$1"
        ;;
      -c)
        shift
        cert_file="$1"
        ;;
      *)
        usage_match
        ;;
    esac
    shift
  done

  [ -z "$privkey_file" ] && echo "A private key file is required." && exit 1
  [ -e "$privkey_file" ] || (echo "The private key file $privkey_file doesn't exist." && exit 1)

  [ -z "$pubkey_file" -a -z "$cert_file" ] && echo "A public key file or certificate file should be specified." && exit 1

  if [ -n "$pubkey_file" ]; then
    [ ! -e "$pubkey_file" ] && echo "The public key file $pubkey_file doesn't exist." && exit 1
    verify "$privkey_file" "$pubkey_file"
    if [ "$?" = "0" ]; then
      echo "The private key matches with the public key."
    fi
  else
    [ ! -e "$cert_file" ] && echo "The certificate file $cert_file doesn't exist." && exit 1
    source "$openssl_dir/pubkey.sh"
    verify "$privkey_file" <(cmd_pubkey "$cert_file")
    if [ "$?" = "0" ]; then
      echo "The private key matches with the certificate."
    fi
  fi
}
alias_cmd m match

verify() {
  echo foo | "$OPENSSL_CMD" dgst -sha256 -verify "$2" -signature <(echo foo | "$OPENSSL_CMD" dgst -sha256 -sign "$1")
}
