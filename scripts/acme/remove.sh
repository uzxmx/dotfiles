usage_remove() {
  cat <<-EOF
Usage: acme remove <cert>

Remove a certificate.
EOF
  exit 1
}

cmd_remove() {
  local cert
  while [ "$#" -gt 0 ]; do
    case "$1" in
      -*)
        usage_remove
        ;;
      *)
        if [ -z "$cert" ]; then
          cert="$1"
        else
          abort "Only one certificate should be specified"
        fi
        ;;
    esac
    shift
  done

  source "$acme_dir/common.sh"

  if [ -z "$cert" ]; then
    cert="$(select_certificate)"
  fi

  source "$DOTFILES_DIR/scripts/lib/prompt.sh"
  [ "$(yesno "Confirm to remove $cert? (y/N)" "no")" = "no" ] && echo Cancelled && exit 1

  run_acme --remove -d "$cert"
}
