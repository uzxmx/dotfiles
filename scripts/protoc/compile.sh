usage_compile() {
  cat <<-EOF
Usage: protoc compile <proto-message-file>...

Compile protocol messages to source files for some programming language.

Options:
  --go compile for golang
EOF
  exit 1
}

cmd_compile() {
  local -a files
  local language
  while [ "$#" -gt 0 ]; do
    case "$1" in
      --go)
        language="go"
        ;;
      -*)
        usage_compile
        ;;
      *)
        files+=("$1")
        ;;
    esac
    shift
  done

  if [ -z "$language" ]; then
    abort "You must specify a language."
  fi

  if [ "${#files[@]}" -eq 0 ]; then
    abort "You must specify one or more proto message files."
  fi

  case "$language" in
    go)
      protoc --go_out=. --go_opt=paths=source_relative "${files[@]}"
      ;;
  esac
}
alias_cmd c compile
