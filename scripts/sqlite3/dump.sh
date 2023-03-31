usage_dump() {
  cat <<-EOF
Usage: sqlite3 dump <db-file>

Dump tables data as a SQL file.

Options:
  -o <file> SQL file to output
  -t <table> table to be dumped
  -c <columns> columns with comma separated, default is '*'
  --no-id Do not export the 'id' column
  -q <conditions> Query conditions, e.g. 'where id > 1'
  --delete Delete the rows after the export
EOF
  exit 1
}

cmd_dump() {
  local db_file file table no_id query_conditions delete
  local columns="*"

  while [ $# -gt 0 ]; do
    case "$1" in
      -t)
        shift
        table="$1"
        ;;
      -c)
        shift
        columns="$1"
        ;;
      -q)
        shift
        query_conditions="$1"
        ;;
      -o)
        shift
        file="$1"
        ;;
      --no-id)
        no_id="1"
        ;;
      --delete)
        delete="1"
        ;;
      -*)
        usage_dump
        ;;
      *)
        if [ -z "$db_file" ]; then
          db_file="$1"
        else
          usage_dump
        fi
        ;;
    esac
    shift
  done

  [ -z "$db_file" ] && abort "A sqlite DB file must be specified."
  [ -z "$file" ] && abort "An output SQL file must be specified."

  source "$DOTFILES_DIR/scripts/lib/utils/join.sh"

  if [ -z "$table" ]; then
    local tables=($(sqlite3 "$db_file" .table))
    table="$(join_to_lines "${tables[@]}" | fzf)"
    [ -z "$table" ] && exit
  fi

  local table_columns
  if [ "$columns" = "*" ]; then
    if [ "$no_id" = "1" ]; then
      columns="$(sqlite3 "$db_file" <<EOF
.headers off
SELECT name FROM PRAGMA_TABLE_INFO('$table');
EOF
)"
      columns=($(echo "$columns" | grep -v id))
      columns="$(join_by , "${columns[@]}")"
    fi

    table_columns="$table"
  else
    table_columns="$table($columns)"
  fi

  sqlite3 "$db_file" <<EOF
.headers on
select count(*) AS 'Count of rows to be dumped' from $table $query_conditions;
.mode insert "$table_columns"
.out $file
select $columns from $table $query_conditions;
EOF

  if [ "$delete" = "1" ]; then
    sqlite3 "$db_file" <<EOF
delete from $table $query_conditions;
.headers on
select count(*) AS 'Count of rows after deletion' from $table $query_conditions;
EOF
  fi

  sed -i '' -e "s/^INSERT INTO \"$table_columns\"/INSERT INTO $table_columns/" "$file"

  echo -e "\nData dumped to $file"
}
alias_cmd d dump
