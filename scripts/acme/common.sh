select_certificate() {
  local cert
  cert="$(run_acme --list | sed 1d | fzf --prompt "Select a certificate: ")"
  echo "$cert" | awk '{print $1}'
}
