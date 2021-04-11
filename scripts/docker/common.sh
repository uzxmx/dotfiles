select_container() {
  local id="$(docker ps --format "table {{.Names}} - {{.Image}}  {{.ID}}" | sed 1d | fzf -d "  " --with-nth=1)"
  if [ -n "$id" ]; then
    echo "$id" | awk '{print $NF}'
  fi
}

select_image() {
  local image="$(docker images --format "{{.Repository}}:{{.Tag}}\t{{.CreatedSince}}" | grep -v '^<none>\|:<none>' | fzf --tiebreak=index)"
  if [ -n "$image" ]; then
    echo "$image" | awk '{print $1}'
  fi
}

select_service() {
  local result="$(docker service ls --format "{{.Name}}\t{{.Image}}" | column -t -s $'\t' | fzf --nth=1)"
  if [ -n "$result" ]; then
    echo "$result" | awk '{print $1}'
  fi
}
