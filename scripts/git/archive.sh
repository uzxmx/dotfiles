usage_a() {
  cat <<-EOF
Usage: g a <output-path> [tree-ish]

Create an archive of files from a named tree (ref), or working directory when
a ref is not specified.

If the format is tar, then it will be gzipped.

Options:
  -f Format of the resulting archive: tar or zip. The format is inferred from
     the filename if possible (e.g. writing to "foo.zip" makes the output to be in
     the zip format)
EOF
  exit 1
}

cmd_a() {
  local dest ref format
  while [ "$#" -gt 0 ]; do
    case "$1" in
      -f)
        shift
        format="$1"
        ;;
      -*)
        usage_a
        ;;
      *)
        if [ -z "$dest" ]; then
          dest="$1"
        else
          ref="$1"
        fi
        ;;
    esac
    shift
  done

  [ -z "$dest" ] && usage_a

  if [ -f "$dest" ]; then
    source "$DOTFILES_DIR/scripts/lib/prompt.sh"
    if [ "$(yesno "File already exists. Are you sure you want to overwrite it? (y/N)" no)" = "no" ]; then
      echo Cancelled
      exit 1
    fi
    rm "$dest"
  fi

  if [ -z "$format" ]; then
    if [[ "$dest" =~ \.zip$ ]]; then
      format="zip"
    else
      format="tar.gz"
    fi
  fi

  if [ -z "$ref" ]; then
    local cmd="git ls-files --others --exclude-standard --cached -z"
    if [ "$format" = "zip" ]; then
      eval "$cmd" | xargs -0 zip "$dest"
    else
      eval "$cmd" | xargs -0 tar -czvf "$dest"
    fi
  else
    git archive --format "$format" --output "$dest" "$ref"
  fi
}
