usage_sync() {
  cat <<-EOF
Usage: cp sync <src-dir> <target-dir>

Sync src dir to target dir, only copy a file when it doesn't exist in the target directory.

Options:
  [--dry-run]
EOF
  exit 1
}

cmd_sync() {
  local dry_run src_dir target_dir
  while [ $# -gt 0 ]; do
    case "$1" in
      --dry-run)
        dry_run="1"
        ;;
      -*)
        usage
        ;;
      *)
        if [ -z "$src_dir" ]; then
          src_dir="$1"
        elif [ -z "$target_dir" ]; then
          target_dir="$1"
        else
          abort "Too many arguments"
        fi
        ;;
    esac
    shift
  done

  local file file_dir file_fullpath
  local file_target_dir file_target_fullpath
  while read file; do
    file_fullpath="$src_dir/$file"
    if [ -d "$file_fullpath" ]; then
      echo "-- Skip directory: $file_fullpath"
      continue
    fi

    file=$(echo "$file" | sed 's:^\./::')
    file_dir="$(dirname "$file")"
    file_target_dir="$target_dir/$file_dir"
    if [ ! -e "$file_target_dir" ]; then
      if [ -z "$dry_run" ]; then
        mkdir -p "$file_target_dir"
      fi
    elif [ ! -d "$file_target_dir" ]; then
      echo "Error: $file_target_dir is not a directory"
      exit 1
    fi

    file_target_fullpath="$file_target_dir/$(basename "$file")"
    if [ -f "$file_target_fullpath" ]; then
      echo "-- Skip existed file: $file_fullpath"
      continue
    fi

    echo cp "$file_fullpath" "$file_target_fullpath"
    if [ -z "$dry_run" ]; then
      cp "$file_fullpath" "$file_target_fullpath"
    fi
  done < <(cd "$src_dir" && find .)
}
