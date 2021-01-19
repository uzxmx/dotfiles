select_container() {
  local id="$(docker ps --format "table {{.Names}} - {{.Image}}  {{.ID}}" | sed 1d | fzf -d "  " --with-nth=1)"
  if [ -n "$id" ]; then
    echo "$id" | awk '{print $NF}'
  fi
}
