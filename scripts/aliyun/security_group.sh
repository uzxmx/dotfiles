source "$aliyun_dir/common.sh"

usage_security_group() {
  cat <<-EOF
Usage: aliyun security_group

Manage security groups.

Subcommands:
  l, list           - list security groups or its entries
  a, authorize      - authorize an entry for a security group
  r, revoke         - revoke an entry for a security group
  u, update_by_desp - update source ip by description
EOF
  exit 1
}

cmd_security_group() {
  local cmd="$1"
  shift || true
  [ -z "$cmd" ] && usage_security_group

  case "$cmd" in
    l | list | a | authorize | r | revoke | u | update_by_desp)
      case "$cmd" in
        l)
          cmd="list"
          ;;
        a)
          cmd="authorize"
          ;;
        r)
          cmd="revoke"
          ;;
        u)
          cmd="update_by_desp"
          ;;
      esac
      case "$1" in
        -h)
          type "usage_security_group_$cmd" &>/dev/null && "usage_security_group_$cmd"
          ;;
      esac
      "cmd_security_group_$cmd" "$@"
      ;;
    *)
      usage_security_group
      ;;
  esac
}
alias_cmd sg security_group

usage_security_group_list() {
  cat <<-EOF
Usage: aliyun security_group list [security_group_id]

List security_groups or its entries.

Options:
  -n <name> the name of the security group to get its entries
  -d <description> filter entries by the description
EOF
  exit 1
}

process_security_group_list_output() {
  jq -r '.SecurityGroups.SecurityGroup[] | "Name: \(.SecurityGroupName)\tSecurityGroupId: \(.SecurityGroupId)\tCreated at: \(.CreationTime)"' | column -t -s $'\t'
}

process_security_group_list_entries_output() {
  jq -r '.Permissions.Permission[] | "\(.Direction)\tPolicy: \(.Policy)\tSourceCidrIP: \(.SourceCidrIp)\tPortRange:\(.PortRange)\tProtocol: \(.IpProtocol)\tDescription: \(.Description)"' | column -t -s $'\t'
}

get_security_group_id_by_name() {
  run_cli '' ecs DescribeSecurityGroups | jq -r ".SecurityGroups.SecurityGroup[] | select(.SecurityGroupName == \"$security_group_name\") | .SecurityGroupId"
}

cmd_security_group_list() {
  local security_group_id security_group_name
  local description
  while [ "$#" -gt 0 ]; do
    case "$1" in
      -n)
        shift
        security_group_name="$1"
        ;;
      -d)
        shift
        description="$1"
        ;;
      -*)
        usage_security_group_list
        ;;
      *)
        security_group_id="$1"
        ;;
    esac
    shift
  done
  process_profile_opts
  if [ -z "$security_group_id" -a -n "$security_group_name" ]; then
    security_group_id="$(get_security_group_id_by_name)"
  fi

  if [ -z "$security_group_id" ]; then
    run_cli process_security_group_list_output ecs DescribeSecurityGroups
  else
    if [ -z "$description" ]; then
      run_cli process_security_group_list_entries_output ecs DescribeSecurityGroupAttribute --SecurityGroupId "$security_group_id"
    else
      run_cli '' ecs DescribeSecurityGroupAttribute --SecurityGroupId "$security_group_id" | jq -r ".Permissions.Permission | map(select(.Description == \"$description\"))"
    fi
  fi
}

usage_security_group_authorize() {
  cat <<-EOF
Usage: aliyun security_group authorize [security_group_id]

Authorize an entry for a security group.

You can specify service types by '-t', so you don't need to specify the source
IP and port. Currently supported type include:

  * http
  * https

Options:
  -n <name> the name of the security group
  -s <source-ip> the source CIDR IP
  -p <port-range> port range, e.g. 443
  --protocol <protocol> TCP by default
  -d <description>

  -t <service-types> service types separated by comma
EOF
  exit 1
}

_common_scripts_for_security_group_entry() {
  local other_opts_process_scripts="$1"
  cat <<EOF
  local security_group_id security_group_name
  local source_ip port
  local protocol="TCP"
  while [ "\$#" -gt 0 ]; do
    case "\$1" in
      -n)
        shift
        security_group_name="\$1"
        ;;
      -s)
        shift
        source_ip="\$1"
        ;;
      -p)
        shift
        port="\$1"
        ;;
      --protocol)
        shift
        protocol="\$1"
        ;;
      -*)
        $other_opts_process_scripts
        ;;
      *)
        security_group_id="\$1"
        ;;
    esac
    shift
  done

  [ -z "\$security_group_id" -a -z "\$security_group_name" ] && echo 'You must specify either a security group id or name.' && exit 1
  true
EOF
}

_sanitize_ip() {
  local ip="$1"
  if [ "$ip" = "0.0.0.0" ]; then
    echo "$ip/0"
  elif [ "$ip" = "${ip%/*}" ]; then
    echo "$ip/32"
  else
    echo "$ip"
  fi
}

_sanitize_port() {
  local port="$1"
  if [ "$port" = "${port%/*}" ]; then
    port="$port/$port"
  else
    echo "$port"
  fi
}

_common_scripts_for_checking_source_ip() {
  cat <<'EOF'
  source_ip="$(_sanitize_ip "$source_ip")"
EOF
}

_common_scripts_for_checking_source_ip_and_port() {
  cat <<EOF
  source "\$dotfiles_dir/scripts/lib/utils/check_variables.sh"
  check_variables source_ip port || exit

  $(_common_scripts_for_checking_source_ip)

  port="\$(_sanitize_port "\$port")"
EOF
}

_common_scripts_for_getting_security_group_id() {
  cat <<'EOF'
  process_profile_opts
  if [ -z "$security_group_id" -a -n "$security_group_name" ]; then
    security_group_id="$(get_security_group_id_by_name)"
    [ -z "$security_group_id" ] && echo "Cannot find the security group id for $security_group_name" && exit 1
  fi
EOF
}

cmd_security_group_authorize() {
  local -a service_types
  local description

  local other_opts_process_scripts="
case "\$1" in
  -d)
    shift
    description="\$1"
    ;;
  -t)
    shift
    source "\$dotfiles_dir/scripts/lib/utils/common.sh"
    source "\$dotfiles_dir/scripts/lib/utils/lines_to_array.sh"
    source "\$dotfiles_dir/scripts/lib/utils/split.sh"
    split_str_into_array "\$1" , service_types
    ;;
  -*)
    usage_security_group_authorize
    ;;
esac
"
  eval "$(_common_scripts_for_security_group_entry "$other_opts_process_scripts")"

  if [ "${#service_types[@]}" -eq 0 ]; then
    eval "$(_common_scripts_for_checking_source_ip_and_port)"
  fi

  eval "$(_common_scripts_for_getting_security_group_id)"

  if [ "${#service_types[@]}" -eq 0 ]; then
    run_cli '' ecs AuthorizeSecurityGroup --SecurityGroupId "$security_group_id" --IpProtocol "$protocol" --PortRange "$port" --SourceCidrIp "$source_ip" --Description "$description" >/dev/null
  else
    for service_type in "${service_types[@]}"; do
      case "$service_type" in
        http)
          run_cli '' ecs AuthorizeSecurityGroup --SecurityGroupId "$security_group_id" --IpProtocol TCP --PortRange 80/80 --SourceCidrIp 0.0.0.0/0 >/dev/null
          ;;
        https)
          run_cli '' ecs AuthorizeSecurityGroup --SecurityGroupId "$security_group_id" --IpProtocol TCP --PortRange 443/443 --SourceCidrIp 0.0.0.0/0 >/dev/null
          ;;
      esac
    done
  fi

  cmd_security_group_list "$security_group_id"
}

usage_security_group_revoke() {
  cat <<-EOF
Usage: aliyun security_group revoke [security_group_id]

Revoke an entry for a security group.

Options:
  -n <name> the name of the security group
  -s <source-ip> the source CIDR IP
  -p <port-range> port range, e.g. 443
  --protocol <protocol> TCP by default
EOF
  exit 1
}

cmd_security_group_revoke() {
  local other_opts_process_scripts="
case "\$1" in
  -*)
    usage_security_group_revoke
    ;;
esac
"
  eval "$(_common_scripts_for_security_group_entry "$other_opts_process_scripts")"
  eval "$(_common_scripts_for_checking_source_ip_and_port)"
  eval "$(_common_scripts_for_getting_security_group_id)"

  run_cli '' ecs RevokeSecurityGroup --SecurityGroupId "$security_group_id" --IpProtocol "$protocol" --PortRange "$port" --SourceCidrIp "$source_ip" >/dev/null

  cmd_security_group_list "$security_group_id"
}

usage_security_group_update_by_desp() {
  cat <<-EOF
Usage: aliyun security_group update_by_desp [security_group_id]

Update source ip by description.

Options:
  -n <name> the name of the security group
  -d <description>
  -s <source-ip> the source CIDR IP
EOF
  exit 1
}

cmd_security_group_update_by_desp() {
  local security_group_id security_group_name
  local description source_ip
  while [ "$#" -gt 0 ]; do
    case "$1" in
      -n)
        shift
        security_group_name="$1"
        ;;
      -d)
        shift
        description="$1"
        ;;
      -s)
        shift
        source_ip="$1"
        ;;
      -*)
        usage_security_group_update_by_desp
        ;;
      *)
        security_group_id="$1"
        ;;
    esac
    shift
  done

  source "$dotfiles_dir/scripts/lib/utils/check_variables.sh"
  check_variables description source_ip || exit

  eval "$(_common_scripts_for_checking_source_ip)"

  process_profile_opts
  if [ -z "$security_group_id" -a -n "$security_group_name" ]; then
    security_group_id="$(get_security_group_id_by_name)"
  fi

  local list="$(cmd_security_group_list "$security_group_id" -d "$description" | jq -r ".[] | (.IpProtocol, .PortRange, .SourceCidrIp)")"

  while read protocol; read port; read ip; do
    if [ ! "$source_ip" = "$(_sanitize_ip "$ip")" ]; then
      cmd_security_group_revoke "$security_group_id" -s "$ip" -p "$port" --protocol "$protocol"
      cmd_security_group_authorize "$security_group_id" -s "$source_ip" -p "$port" --protocol "$protocol" -d "$description"
    fi
  done < <(echo "$list")
}
