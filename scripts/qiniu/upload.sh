source "$(dirname "$BASH_SOURCE")/common.sh"

usage_upload() {
  cat <<-EOF
Usage: qiniu upload <file>...

Upload one or more files to qiniu storage.

By default you can only upload a file successfully if the key doesn't exist in
the storage. If you want to override the file, specify '-o' option.

Options:
  -k <access_key> access key
  -s <secret_key> secret key
  -b <bucket> bucket
  -K <key> file key, when this is specified, you can only upload a file one time
  -o whether to override the file or not when a file exists with the same key
  -r indicate files should be fetched from remote by curl
EOF
  exit 1
}

cmd_upload() {
  local -a files

  source "$qiniu_dir/common_options.sh"

  local key_arg fetch_from_remote
  local insert_only="1"
  while [ "$#" -gt 0 ]; do
    case "$1" in
      -K)
        shift
        key_arg="$1"
        ;;
      -o)
        insert_only="0"
        ;;
      -r)
        fetch_from_remote="1"
        ;;
      -*)
        usage_upload
        ;;
      *)
        [ -z "$fetch_from_remote" ] && [ ! -f "$1" ] && abort "$1 is not a file"
        files+=("$1")
        ;;
    esac
    shift
  done

  [ "${#files[@]}" -eq 0 ] && abort 'At least a file should be specified'

  if [ -n "$fetch_from_remote" ]; then
    source "$dotfiles_dir/scripts/lib/tmpfile.sh"
    source "$dotfiles_dir/scripts/lib/url.sh"
  fi

  local file key upload_token tmpfile
  for file in "${files[@]}"; do
    if [ -n "$key_arg" ]; then
      key="$key_arg"
    elif [ -n "$fetch_from_remote" ]; then
      key="$(url_get_path "$file" 1)"
    else
      key="$(basename "$file")"
    fi

    if [ -n "$fetch_from_remote" ]; then
      create_tmpfile tmpfile
      echo "$tmpfile"
      curl -s -L -k -o "$tmpfile" "$file"
      file="$tmpfile"
    fi

    upload_token="$(get_upload_token "$key" "$insert_only")"
    # For a list of upload endpoints, please visit https://developer.qiniu.com/kodo/1671/region-endpoint-fq
    curl -F "file=@$file" -F "key=$key" -F "token=$upload_token" https://upload.qiniup.com

    [ -n "$key_arg" ] && exit
  done
}
alias_cmd u upload
