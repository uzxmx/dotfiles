usage_time() {
  cat <<-EOF
Usage: curl time <url>

Show time stats.

Example:
  $> curl time example.com
EOF
  exit 1
}

cmd_time() {
  [ -z "$1" ] && usage_time

  curl -w "\
    \n-------------------------\n\
       namelookup:  %{time_namelookup}s\n\
          connect:  %{time_connect}s\n\
       appconnect:  %{time_appconnect}s\n\
      pretransfer:  %{time_pretransfer}s\n\
         redirect:  %{time_redirect}s\n\
    starttransfer:  %{time_starttransfer}s\n\
    -------------------------\n\
            total:  %{time_total}s\n" "$@"
}
