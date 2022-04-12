copy_with_intermediate_paths() {
  local file="$1"
  local dest_dir="$2"
  local dest_file="$dest_dir/$file"
  mkdir -p "$(dirname "$dest_file")"
  echo "Copy $file to $dest_file"
  cp "$file" "$dest_file"
}
