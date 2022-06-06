source "$(dirname "$BASH_SOURCE")/common.sh"

usage_list() {
  cat <<-EOF
Usage: qiniu list

List files.

Options:
  -k <access_key> access key
  -s <secret_key> secret key
  -b <bucket> bucket
  -a list all files, and dump the result to json files. In this case, the limit is set to 1000 for each fetch
  -l <limit> the number of results to limit, default is 10, should be within 1 - 1000
EOF
  exit 1
}

cmd_list() {
  source "$qiniu_dir/common_options.sh"
  check_keys_and_bucket

  local list_all
  local limit=10
  while [ "$#" -gt 0 ]; do
    case "$1" in
      -a)
        list_all=1
        ;;
      -l)
        shift
        if [ "$1" -lt 1000 ]; then
          limit="$1"
        else
          limit=1000
        fi
        ;;
      *)
        usage_list
        ;;
    esac
    shift
  done

  if [ -n "$list_all" ]; then
    limit=1000
  fi

  local i=1
  local marker
  source "$DOTFILES_DIR/scripts/lib/url.sh"
  while true; do
    local query="bucket=$bucket&limit=$limit&marker="
    if [ -n "$marker" ]; then
      query="$query$(url_encode "$marker")"
    fi
    local result="$(get_req /list "$query" "" "rsf.qbox.me")"
    if [ -n "$list_all" ]; then
      local file="${bucket}_$i.json"
      if [ -e "$file" ]; then
        abort "The file to be generated is $file, but it already exists. Please remove it first."
      fi
      echo "$result" >"$file"
      echo "Generated $file"
      marker="$(echo "$result" | jq -r '.marker | values')"
      [ -z "$marker" ] && break
      i=$((i + 1))
    else
      process_output | column -t -s $'\t'
      break
    fi
  done
}
alias_cmd l list

process_output() {
  local line
  echo -e "Key\tMime Type\tPut Time"
  while read line; do
    local key="$(echo "$line" | jq -r '.key')"
    local mime_type="$(echo "$line" | jq -r '.mimeType')"
    local put_time="$(echo "$line" | jq -r '.putTime')"
    local unix_time="$(($put_time / 10000000))"
    echo -e "${key:- }\t$mime_type\t$(date -r "$unix_time")"
  done < <(echo "$result" | jq -c '.items[]')
}
