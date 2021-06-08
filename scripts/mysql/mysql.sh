usage_source() {
  cat <<-EOF
Usage: mysql source

Source a sql file.

Examples:
  mysql source <foo.sql
EOF
  exit 1
}

cmd_source() {
  docker_extra_opts=(-i)
  # --no-auto-rehash will make it faster to connect, see mysql --auto-rehash
  run_cli --no-auto-rehash "$@"
}
alias_cmd s "source"

usage_connect() {
  cat <<-EOF
Usage: mysql connect

Connect to the server.
EOF
  exit 1
}

cmd_connect() {
  docker_extra_opts=(-it)
  cat <<EOF >&2
NOTE:
Auto rehash for completion is disabled by default to make it faster to connect.
You can enable it in current session by executing 'rehash'.
Also see mysql --auto-rehash.

EOF
  run_cli --no-auto-rehash "$@"
}
alias_cmd c "connect"

cmd_server_version() {
  cmd_source "$@" < <(cat <<EOF
SHOW VARIABLES LIKE "%version%";
EOF
)
}
alias_cmd sv "server_version"
