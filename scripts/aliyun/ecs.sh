source "$aliyun_dir/common.sh"

usage_ecs() {
  cat <<-EOF
Usage: aliyun ecs

Manage elastic compute service.

Subcommands:
  r, regions - list regions
  l, list    - list instances
  g, get     - get an instance
EOF
  exit 1
}

cmd_ecs() {
  local cmd="$1"
  shift || true
  [ -z "$cmd" ] && usage_ecs

  case "$cmd" in
    l | list | r | regions | g | get)
      case "$cmd" in
        l)
          cmd="list"
          ;;
        r)
          cmd="regions"
          ;;
        g)
          cmd="get"
          ;;
      esac
      case "$1" in
        -h)
          type "usage_ecs_$cmd" &>/dev/null && "usage_ecs_$cmd"
          ;;
      esac
      "cmd_ecs_$cmd" "$@"
      ;;
    *)
      usage_ecs
      ;;
  esac
}
alias_cmd e ecs

process_ecs_list_output() {
  jq -r '.Instances.Instance[] | "ID: \(.InstanceId)\tDescription: \(.Description)\tPrivate IP: \(.VpcAttributes.PrivateIpAddress.IpAddress[])\tPublic IP: \(.PublicIpAddress.IpAddress[])\tVPC ID: \(.VpcAttributes.VpcId)\tSecurityGroup: \(.SecurityGroupIds.SecurityGroupId[])"' | column -t -s $'\t'
}

cmd_ecs_list() {
  process_profile_opts
  run_cli process_ecs_list_output ecs DescribeInstances
}

usage_ecs_regions() {
  cat <<-EOF
Usage: aliyun ecs regions

List regions.
EOF
  exit 1
}

process_ecs_regions_output() {
  jq -r '.Regions.Region[] | "Region ID: \(.RegionId)\tName: \(.LocalName)\tEndpoint: \(.RegionEndpoint)"' | column -t -s $'\t'
}

cmd_ecs_regions() {
  process_profile_opts
  run_cli process_ecs_regions_output ecs DescribeRegions
}

usage_ecs_get() {
  cat <<-EOF
Usage: aliyun ecs get [instance_id]

Get an instance.

Options:
  -d <description> find instance by the description
EOF
  exit 1
}

cmd_ecs_get() {
  local instance_id description
  while [ "$#" -gt 0 ]; do
    case "$1" in
      -d)
        shift
        description="$1"
        ;;
      -*)
        usage_ecs_get
        ;;
      *)
        instance_id="$1"
    esac
    shift
  done

  [ -z "$instance_id" ] && echo 'An instance ID is required.' && exit 1

  process_profile_opts
  run_cli '' ecs DescribeInstanceAttribute --InstanceId "$instance_id"
}
