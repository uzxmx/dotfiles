workspace="$BITBUCKET_WORKSPACE_SLUG"
project_key="$BITBUCKET_PROJECT_KEY"

remainder=()
while [ "$#" -gt 0 ]; do
  case "$1" in
    -w)
      shift
      workspace="$1"
      ;;
    -k)
      shift
      project_key="$1"
      ;;
    *)
      remainder+=("$1")
      ;;
  esac
  shift
done

set - "${remainder[@]}"

check_workspace() {
  if [ -z "$workspace" ]; then
    echo "You must specify a workspace ether by -w option or BITBUCKET_WORKSPACE_SLUG environment variable."
    exit 1
  fi
}

check_project_key() {
  if [ -z "$project_key" ]; then
    echo "You must specify a project key ether by -k option or BITBUCKET_PROJECT_KEY environment variable."
    exit 1
  fi
}
