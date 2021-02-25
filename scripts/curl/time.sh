usage_time() {
  cat <<-EOF
Usage: curl time <url>

Show time stats.

Options:
  - indicate options after this are used as curl options

Example:
  $> curl time example.com
EOF
  exit 1
}

cmd_time() {
  local url
  local -a remainder
  while [ "$#" -gt 0 ]; do
    case "$1" in
      -)
        shift
        while [ "$#" -gt 0 ]; do
          remainder+=("$1")
          shift
        done
        break
        ;;
      -*)
        usage_time
        ;;
      *)
        url="$1"
        ;;
    esac
    shift
  done

  [ -z "$url" ] && usage_time

  curl -w "\
    \n-------------------------\n\
       namelookup:  %{time_namelookup}s\n\
          connect:  %{time_connect}s\n\
       appconnect:  %{time_appconnect}s\n\
      pretransfer:  %{time_pretransfer}s\n\
         redirect:  %{time_redirect}s\n\
    starttransfer:  %{time_starttransfer}s\n\
    -------------------------\n\
            total:  %{time_total}s\n" -D - -o /dev/null -s "${remainder[@]}" "$url"
}
