prepare_sql() {
  local sql="$1"
  shift
  declare -a args=("$@")

  sql=${sql//[%]/%%}
  sql=${sql//[?]/UNHEX(\'%s\')}
  for ((i=0; i<${#args[@]}; i++)); do
    args[$i]=$(echo -n "${args[$i]}" | hexdump -v -e '/1 "%02X"')
  done
  printf "$sql" "${args[@]}"
}

select_tables() {
  local db="$1"
  shift
  local tables="$("$dotfiles_dir/bin/mysql" source "$@" < <(prepare_sql "SELECT table_name FROM information_schema.tables WHERE table_schema = ?;" "$db"))"
  if [ -n "$tables" ]; then
    echo "$tables" | fzf -m --prompt "Select tables> "
  fi
}
