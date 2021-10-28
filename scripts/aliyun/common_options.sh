while [ "$#" -gt 0 ]; do
  case "$1" in
    --region)
      shift
      region="$1"
      ;;
    --access-key-id)
      shift
      access_key_id="$1"
      ;;
    --access-key-secret)
      shift
      access_key_secret="$1"
      ;;
    *)
      remainder+=("$1")
      ;;
  esac
  shift
done

set - "${remainder[@]}"
