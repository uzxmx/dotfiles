usage_tree() {
  cat <<-EOF
Usage: ps tree <pid>

Show the process tree of a pid with full command lines.

Runs 'pstree -sap <pid>':
  -s  show parent chain up to init/systemd
  -a  show full command line arguments
  -p  show pids

Example:
  $> ps tree 1234
EOF
  exit 1
}

cmd_tree() {
  local pid="$1"
  [ -z "$pid" ] && usage_tree
  pstree -sap "$pid"
}
