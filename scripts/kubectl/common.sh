select_pod() {
  local result="$(run_cli get pods -o custom-columns=NAME:.metadata.name,Status:.status.phase --no-headers | fzf -d " " --nth=1)"
  if [ -n "$result" ]; then
    echo "$result" | awk '{print $1}'
  fi
}

select_service() {
  local result="$(run_cli get service -o custom-columns=NAME:.metadata.name,Ports:.spec.ports..port --no-headers | fzf -d " " --nth=1)"
  if [ -n "$result" ]; then
    echo "$result" | awk '{print $1}'
  fi
}
