usage_add() {
  cat <<-EOF
Usage: proxy-users add <name> [--nodes hk,jp,us]

Add a user. Creates one UUID per node, wires up routing so each node's
traffic reaches mihomo tagged with that node, then prints share links.

Options:
  --nodes <list>   comma-separated subset of: ${NODES[*]} (default: all)

Examples:
  proxy-users add alice
  proxy-users add bob --nodes hk,jp
EOF
  exit 1
}

cmd_add() {
  need xray; need jq
  require_config; require_meta

  local name="" nodes_arg=""
  while [ "$#" -gt 0 ]; do
    case "$1" in
      --nodes) nodes_arg="$2"; shift ;;
      -h) usage_add ;;
      -*) die "Unknown argument '$1'" ;;
      *) [ -z "$name" ] && name="$1" || die "Unexpected argument '$1'" ;;
    esac
    shift
  done
  [ -z "$name" ] && usage_add
  valid_name "$name"
  user_exists "$name" && die "User '$name' already exists"

  local nodes_str
  nodes_str="$(parse_nodes "$nodes_arg")" || exit 1
  local -a nodes
  read -ra nodes <<<"$nodes_str"

  local node email uuid
  for node in "${nodes[@]}"; do
    email="$name-$node"
    uuid="$(xray uuid)"
    read_config | jq \
      --arg id "$uuid" --arg email "$email" --arg otag "n-$node" --arg flow "$FLOW" '
      (.inbounds[] | select(.tag=="vless-in") | .settings.clients)
        += [{ "id": $id, "email": $email, "flow": $flow }]
      | if any(.routing.rules[]?; .outboundTag == $otag)
        then .routing.rules |= map(
               if .outboundTag == $otag
               then .user = ((.user // []) + [$email])
               else . end)
        else .routing.rules += [{ "type": "field", "outboundTag": $otag, "user": [$email] }]
        end
    ' | write_config
  done

  reload_xray

  echo
  echo "Added '$name' with nodes: ${nodes[*]}"
  echo "Share links:"
  load_meta
  print_sub "$name"
}
