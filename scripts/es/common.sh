select_index() {
  req "/_cat/indices?h=index" -s | fzf --select-1 -0 --prompt "Select an index: " || true
}

remainder=()
while [ "$#" -gt 0 ]; do
  case "$1" in
    -v)
      log_request=1
      ;;
    *)
      remainder+=("$1")
      ;;
  esac
  shift
done

set - "${remainder[@]}"
