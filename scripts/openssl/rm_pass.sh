usage_rm_pass() {
  cat <<-EOF
Usage: openssl rm_pass <priv-key-file>

Remove passphrase from a private key. Shell pipe is also supported.
EOF
  exit 1
}

cmd_rm_pass() {
  if [ ! -t 0 ]; then
    openssl rsa -in -
  else
    [ ! -f "$1" ] && echo 'A private key file is required.' && exit 1
    openssl rsa -in "$1"
  fi
}
