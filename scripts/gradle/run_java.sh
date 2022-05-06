usage_run_java() {
  cat <<-EOF
Usage: gradle run_java <main-class>

Run a java main class for a gradle based project.

Options:
  -m <module> the project module which the main class belongs to, e.g. 'app'
EOF
  exit 1
}

cmd_run_java() {
  local main_class module
  while [ "$#" -gt 0 ]; do
    case "$1" in
      -m)
        shift
        module="$1"
        ;;
      -*)
        usage_run_java
        ;;
      *)
        [ -n "$main_class" ] && echo "Only one main class can be specified." && exit 1
        main_class="$1"
        ;;
    esac
    shift
  done

  [ -z "$main_class" ] && echo "A java main class must be specified." && exit 1

  local task="runWithJavaExec"
  if [ -n "$module" ]; then
    task=":$module:$task"
  fi

  run_task java.gradle "$task" -PmainClass="$main_class"
}
