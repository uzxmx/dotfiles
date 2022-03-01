usage_allow_ptrace() {
  cat <<-EOF
Usage: gdb allow_ptrace

Allow gdb to attach to a process. For more info, please see
/etc/sysctl.d/10-ptrace.conf
EOF
  exit 1
}

cmd_allow_ptrace() {
  local value="$(cat /etc/sysctl.d/10-ptrace.conf | grep "^kernel.yama.ptrace_scope" | awk -F= '{print $2}' | sed "s/ //")"
  if [ ! "$value" = 1 ]; then
    sudo sed -i -E 's/^(kernel\.yama\.ptrace_scope.*)$/#\1/' /etc/sysctl.d/10-ptrace.conf
    echo "kernel.yama.ptrace_scope = 0" | sudo tee -a /etc/sysctl.d/10-ptrace.conf >/dev/null
  fi
  sudo sysctl -w kernel.yama.ptrace_scope=0
}
