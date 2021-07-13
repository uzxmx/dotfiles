source "$aliyun_dir/common.sh"

usage_nat() {
  cat <<-EOF
Usage: aliyun nat

Manage NAT gateways.

Subcommands:
  l, list - list NAT
  g, get  - get a NAT
EOF
  exit 1
}

cmd_nat() {
  local cmd="$1"
  shift || true
  [ -z "$cmd" ] && usage_nat

  case "$cmd" in
    l | list | g | get)
      case "$cmd" in
        l)
          cmd="list"
          ;;
        g)
          cmd="get"
          ;;
      esac
      case "$1" in
        -h)
          type "usage_nat_$cmd" &>/dev/null && "usage_nat_$cmd"
          ;;
      esac
      "cmd_nat_$cmd" "$@"
      ;;
    *)
      usage_nat
      ;;
  esac
}
alias_cmd n nat

process_nat_list_output() {
  jq -r '.NatGateways.NatGateway[] | "ID: \(.NatGatewayId)\tName: \(.Name)\tDescription: \(.Description)\tStatus: \(.Status)\tVPC ID: \(.VpcId)"' | column -t -s $'\t'
}

cmd_nat_list() {
  process_profile_opts
  run_cli process_nat_list_output ecs DescribeNatGateways
}

usage_nat_get() {
  cat <<-EOF
Usage: aliyun nat get [gateway_id]

Get a NAT.
EOF
  exit 1
}

cmd_nat_get() {
  local gateway_id
  while [ "$#" -gt 0 ]; do
    case "$1" in
      -*)
        usage_nat_get
        ;;
      *)
        gateway_id="$1"
    esac
    shift
  done

  [ -z "$gateway_id" ] && echo 'A NAT gateway ID is required.' && exit 1

  process_profile_opts
  run_cli '' vpc GetNatGatewayAttribute --NatGatewayId "$gateway_id"
}
