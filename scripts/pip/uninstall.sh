usage_uninstall() {
  cat <<-EOF
Usage: pip uninstall

Select installed packages via fzf (tab for multi-select) and uninstall them
directly without confirmation.
EOF
  exit 1
}

cmd_uninstall() {
  local packages
  packages=$(pip list 2>/dev/null | tail -n +3 | fzf -m --preview="pip show {1}" | awk '{print $1}')

  [ -z "$packages" ] && return 0

  echo "$packages" | xargs pip uninstall -y
}

alias_cmd u uninstall
