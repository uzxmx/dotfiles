usage_unshallow() {
  cat <<-EOF
Usage: g unshallow

Make a full clone for a shallow one.
EOF
  exit 1
}

cmd_unshallow() {
  git config remote.origin.fetch "+refs/heads/*:refs/remotes/origin/*"
  git remote update
  git fetch --unshallow
}
