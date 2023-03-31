usage_import() {
  cat <<-EOF
Usage: sqlite3 import <db-file> <sql-file>

Import data from a SQL file.
EOF
  exit 1
}

cmd_import() {
  local db_file="$1"
  local file="$2"

  [ -z "$db_file" ] && abort "A sqlite DB file must be specified."
  [ -z "$file" ] && abort "A SQL file must be specified."

  sqlite3 "$db_file" ".read $file"
}
