usage_remote_archetypes() {
  cat <<-EOF
Usage: mvn remote_archetypes

Get remote archetypes.
EOF
  exit 1
}

cmd_remote_archetypes() {
  local tmpfile="$(mktemp)"
  "$dotfiles_dir/bin/get" "https://repo.maven.apache.org/maven2/archetype-catalog.xml" "$tmpfile"
  "${EDITOR:-vim}" "$tmpfile"
  rm -rf "$tmpfile"
}
