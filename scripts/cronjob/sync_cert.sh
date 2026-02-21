usage_sync_cert() {
  cat <<-EOF
Usage: cronjob sync_cert -n <name> -h <server_host> <user@ip>...

Sync ssl cert by ssh.

Options:
  -n <name>
  -h <server_host> server host to check if certificate should be uploaded
EOF
  exit 1
}

cmd_sync_cert() {
  local name
  local -a hosts
  while [ "$#" -gt 0 ]; do
    case "$1" in
      -n)
        shift
        name="$1"
        ;;
      -h)
        shift
        server_host="$1"
        ;;
      -*)
        usage_sync_cert
        ;;
      *)
        hosts+=("$1")
        ;;
    esac
    shift
  done

  [ -z "$name" ] && usage_sync_cert
  [ -z "$server_host" ] && usage_sync_cert
  [ "${#hosts}" -eq 0 ] && abort "At least one ssh host should be specified"

  generate_script_fn() {
    cat <<EOF >"$1"
#!/usr/bin/env bash
#
# Generated. Do Not Edit.

"$DOTFILES_DIR/bin/acme" upload_cert -n "$name" -h "$server_host" "${hosts[@]}" &>"/tmp/sync_cert-$server_host.log"
EOF
  }

  source "$DOTFILES_DIR/scripts/lib/cron.sh"
  create_cron_job_file "sync_cert-$server_host.sh" "31 2 * * *" generate_script_fn
}
