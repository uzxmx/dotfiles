while [ "$#" -gt 0 ]; do
  case "$1" in
    -w)
      shift
      workspace_path="$1"
      ;;
    -p)
      shift
      project_path="$1"
      ;;
    *)
      remainder+=("$1")
      ;;
  esac
  shift
done

set - "${remainder[@]}"
