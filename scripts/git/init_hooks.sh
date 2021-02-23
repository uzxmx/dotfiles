usage_init_hooks() {
  cat <<-EOF
Usage: g init_hooks

Initialize git hooks and trigger post-checkout hook. This requires a directory
named as '.githooks' exist in the root folder of the repository.

Options:
  -q do not show error
EOF
  exit 1
}

cmd_init_hooks() {
  local quiet
  while [ "$#" -gt 0 ]; do
    case "$1" in
      -q)
        quiet=1
        ;;
      *)
        usage_init_hooks
        ;;
    esac
    shift
  done

  cd "$(git rev-parse --show-toplevel)"

  if [ ! -d ".githooks" ]; then
    [ "$quiet" = "1" ] || echo "A directory named as '.githooks' is required."
    exit 1
  fi

  git config core.hooksPath .githooks
  ./.githooks/post-checkout
}
