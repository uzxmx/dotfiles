usage_renew() {
  cat <<-EOF
Usage: acme renew [domain]

Renew certificate for domain.

Options:
  -a Renew all certificates
  -f Force to renew even if it's not the time

Examples:
  # Renew a certificate
  acme renew "*.example.com"

  # Renew all certificates
  acme renew -a
EOF
  exit 1
}

cmd_renew() {
  local renew_all domain
  local -a renew_opts
  while [ "$#" -gt 0 ]; do
    case "$1" in
      -a)
        renew_all=1
        ;;
      -f)
        renew_opts=(--force)
        ;;
      -*)
        usage_renew
        ;;
      *)
        domain="$1"
        ;;
    esac
    shift
  done

  if [ "$renew_all" = "1" ]; then
    run_acme --renew-all "${renew_opts[@]}"
  elif [ -n "$domain" ]; then
    run_acme --renew "${renew_opts[@]}" -d "$domain"
  else
    abort "You need to specify either a domain or '-a' option."
  fi
}
