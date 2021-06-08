source "$mysql_dir/common.sh"

usage_nodata() {
  cat <<-EOF
Usage: mysqldump nodata <db>

Dump a complete database without data.
EOF
  exit 1
}

cmd_nodata() {
  local remainder=()
  while [ "$#" -gt 0 ]; do
    case "$1" in
      --help)
        usage_nodata
        ;;
      *)
        remainder+=("$1")
        ;;
    esac
    shift
  done

  set - "${remainder[@]}"

  $mysqldump --no-data "$@"
}

usage_data() {
  cat <<-EOF
Usage: mysqldump data <db> [table]...

Dump specifc tables data.
EOF
  exit 1
}

cmd_data() {
  local db
  local -a tables
  local remainder=()
  while [ "$#" -gt 0 ]; do
    case "$1" in
      --help)
        usage_data
        ;;
      -*)
        remainder+=("$1")
        if [ "$1" = "-h" ]; then
          shift
          remainder+=("$1")
        fi
        ;;
      *)
        if [ -z "$db" ]; then
          db="$1"
        else
          tables+=("$1")
        fi
        remainder+=("$1")
        ;;
    esac
    shift
  done

  [ -z "$db" ] && echo "A db is required." && exit 1

  set - "${remainder[@]}"

  if [ "${#tables[@]}" -eq 0 ]; then
    tables=($(select_tables "$db" "$@"))
    [ "${#tables[@]}" -eq 0 ] && echo "At least a table is required." && exit 1
  fi

  $mysqldump --no-create-info "$@" "${tables[@]}"
}
