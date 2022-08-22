usage_update_taps() {
  cat <<-EOF
Usage: brew update_taps

Update taps with progress, can be run before the official update command.

Sometimes, it's slow to run 'brew update', and we don't know what's happening.
We can run this command to fetch the updates with progress, and then run 'brew
update' to do the remaining things.
EOF
  exit 1
}

cmd_update_taps() {
  local homebrew_library="$(brew --repo)/Library"
  local dir
  for dir in "$homebrew_library"/Taps/*/*; do
    echo "Fetching for $dir"
    cd "$dir" && git fetch --progress -v --tags --force origin refs/heads/master:refs/remotes/origin/master || true
    echo "Finished fetching"
  done
}
