[ -e ~/.vpn_env ] && source ~/.vpn_env

check_env_variable() {
  [ -z "$(eval echo \$$1)" ] && echo "Environment variable $1 must be defined in '~/.vpn_env'." && exit 1
  true
}

is_ppp_device_available() {
  route | grep ppp &>/dev/null
}
