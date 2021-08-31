while [ "$#" -gt 0 ]; do
  case "$1" in
    -k)
      shift
      access_key="$1"
      ;;
    -s)
      shift
      secret_key="$1"
      ;;
    -b)
      shift
      bucket="$1"
      ;;
    *)
      remainder+=("$1")
      ;;
  esac
  shift
done

set - "${remainder[@]}"
