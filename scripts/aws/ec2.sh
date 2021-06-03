source "$aws_dir/common.sh"

usage_ec2() {
  cat <<-EOF
Usage: aws ec2

Manage elastic compute service.

Subcommands:
  r, regions - list regions
  l, list    - list instances
  g, get     - get an instance
EOF
  exit 1
}

cmd_ec2() {
  local cmd="$1"
  shift || true
  [ -z "$cmd" ] && usage_ec2

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
          type "usage_ec2_$cmd" &>/dev/null && "usage_ec2_$cmd"
          ;;
      esac
      "cmd_ec2_$cmd" "$@"
      ;;
    *)
      usage_ec2
      ;;
  esac
}
alias_cmd e ec2

process_ec2_list_output() {
  jq -r '.Reservations[] | .Instances[] | "ID: \(.InstanceId)\tName: \(.Tags | map({ (.Key): .Value }) | add | .Name)\tInstanceType: \(.InstanceType)\tPublicIpAddress: \(.PublicIpAddress)\tPrivateIpAddress: \(.PrivateIpAddress)\tVpcId: \(.VpcId)"' | column -t -s $'\t'
}

cmd_ec2_list() {
  process_profile_opts
  run_cli process_ec2_list_output ec2 describe-instances
}

usage_ec2_regions() {
  cat <<-EOF
Usage: aws ec2 regions

List regions.
EOF
  exit 1
}

process_ec2_regions_output() {
  jq -r '.Regions[] | "Region Name: \(.RegionName)\tEndpoint: \(.Endpoint)"' | column -t -s $'\t'
}

cmd_ec2_regions() {
  process_profile_opts
  run_cli process_ec2_regions_output ec2 describe-regions --all-regions
}

usage_ec2_get() {
  cat <<-EOF
Usage: aws ec2 get [instance_id]

Get an instance.

Options:
  -d <description> find instance by the description
EOF
  exit 1
}

cmd_ec2_get() {
  local instance_id description
  while [ "$#" -gt 0 ]; do
    case "$1" in
      -d)
        shift
        description="$1"
        ;;
      -*)
        usage_ec2_get
        ;;
      *)
        instance_id="$1"
    esac
    shift
  done

  [ -z "$instance_id" ] && echo 'An instance ID is required.' && exit 1

  process_profile_opts
  run_cli '' ec2 describe-instances --instance-ids "$instance_id" | jq -r '.Reservations[] | .Instances[]'
}
