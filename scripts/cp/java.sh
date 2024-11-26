source "$cp_dir/common.sh"

usage_java() {
  cat <<-EOF
Usage: cp java <path-to-src-package> <path-to-dest-package>

Copy java package to another location with package/import statements substituted.

Examples:
  $> cp java project/src/main/java/com/example/foo another_project/src/main/java/com/bar
EOF
  exit 1
}

parse_package_path() {
  echo "$1" | "$SED" -E 's:.*/src/(main|test)/java/(.+)$:\2:' | "$SED" 's:/$::'
}

convert_to_escaped_dot_path() {
  echo "$1" | sed -e 's:/:\\.:g'
}

cmd_java() {
  local dest_dir="${@: -1}"
  local create_subdir
  if [ -e "$dest_dir" -o "$#" -gt 2 ]; then
    create_subdir=1
  fi

  source "$DOTFILES_DIR/scripts/lib/gsed.sh"

  local file target_dir
  for file in "${@:1:$(($# - 1))}"; do
    local basename=
    if [ "$create_subdir" = "1" ]; then
      target_dir="$dest_dir/$(basename "$file")"
    else
      target_dir="$dest_dir"
    fi
    echo "Copy $file to $target_dir"
    cp -R "$file" "$target_dir"

    local src_package="$(convert_to_escaped_dot_path $(parse_package_path "$(realpath $file)"))"
    local dest_package="$(convert_to_escaped_dot_path $(parse_package_path "$(realpath $target_dir)"))"
    while read file; do
      "$SED" -i "s/$src_package\./$dest_package\./g" "$file"
      "$SED" -i "s/$src_package;/$dest_package;/g" "$file"
    done < <(find "$target_dir" -name "*.java")
  done
}
