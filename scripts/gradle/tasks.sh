usage_tasks() {
  cat <<-EOF
Usage: gradle tasks

Compared to the original behavior, this subcommand by default shows all tasks.
You can use '--no-all' to disable this.

Options:
  --no-all
EOF
  exit 1
}

cmd_tasks() {
  local no_all
  local -a args
  while [ "$#" -gt 0 ]; do
    case "$1" in
      --no-all)
        no_all=1
        ;;
      *)
        args+=("$1")
        ;;
    esac
    shift
  done

  if [ -z "$no_all" ]; then
    "$gradle_bin" tasks --all "${args[@]}"
  else
    "$gradle_bin" tasks "${args[@]}"
  fi
}
