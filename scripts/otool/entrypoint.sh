usage_entrypoint() {
  cat <<-EOF
Usage: otool entrypoint <executable>

Show entrypoint address for an executable.
EOF
  exit 1
}

cmd_entrypoint() {
  local file="$1"
  if [ ! -x "$file" ]; then
    echo "An executable file is required"
    exit 1
  fi

  otool -s __TEXT __text "$file" | head -n 3 | tail -n 1 | awk '{print $1}'
}
alias_cmd e entrypoint
