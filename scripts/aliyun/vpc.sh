source "$aliyun_dir/common.sh"

usage_vpc() {
  cat <<-EOF
Usage: aliyun vpc

Manage virtual private cloud.

Subcommands:
  l, list - list VPC
EOF
  exit 1
}

cmd_vpc() {
  local cmd="$1"
  shift || true
  [ -z "$cmd" ] && usage_vpc

  case "$cmd" in
    l | list)
      case "$cmd" in
        l)
          cmd="list"
          ;;
      esac
      case "$1" in
        -h)
          type "usage_vpc_$cmd" &>/dev/null && "usage_vpc_$cmd"
          ;;
      esac
      "cmd_vpc_$cmd" "$@"
      ;;
    *)
      usage_vpc
      ;;
  esac
}
alias_cmd v vpc

process_vpc_list_output() {
  jq -r '.Vpcs.Vpc[] | "ID: \(.VpcId)\tName: \(.VpcName)\tCidrBlock: \(.CidrBlock)\tNatGatewayIds: \(.NatGatewayIds.NatGatewayIds[])"' | column -t -s $'\t'
}

cmd_vpc_list() {
  process_profile_opts
  run_cli process_vpc_list_output vpc DescribeVpcs
}
