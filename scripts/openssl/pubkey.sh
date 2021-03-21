source "$openssl_dir/x509_common.sh"

usage_pubkey() {
  local cmd="pubkey"
  local description="Get public key for a certificate."
  eval "$(common_scripts_for_x509_help)"
}

cmd_pubkey() {
  local x509_opts=(-pubkey)
  local usage_fn="usage_pubkey"
  eval "$(common_scripts_for_x509)"
}
