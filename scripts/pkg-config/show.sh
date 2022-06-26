usage_show() {
  cat <<-EOF
Usage: pkg-config show [package-name]

Show details of a package.
EOF
  exit 1
}

cmd_show() {
  local pkg="$1"
  if [ -z "$pkg" ]; then
    pkg="$(pkg-config --list-all | fzf | awk '{print $1}')"
  fi
  if ! pkg-config --exists "$pkg"; then
    echo "Package '$pkg' doesn't exist."
  else
    echo "package: $pkg"
    echo "version: $(pkg-config --modversion "$pkg")"
    echo "cflags: $(pkg-config --cflags "$pkg")"
    echo "linker flags: $(pkg-config --libs "$pkg")"
  fi
}
alias_cmd s show
