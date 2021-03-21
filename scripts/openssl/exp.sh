source "$openssl_dir/x509_common.sh"

usage_exp() {
  local cmd="exp"
  local description="Show expiration info of a certificate."
  eval "$(common_scripts_for_x509_help)"
}

cmd_exp() {
  local x509_opts=(-dates)
  local usage_fn="usage_exp"
  eval "$(common_scripts_for_x509)"
}
alias_cmd e exp
