#!/usr/bin/env bash
#
# Example:
#
#   ./curl_time.sh 'http://www.baidu.com' -H 'Accept: application/json, text/plain, */*'

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
