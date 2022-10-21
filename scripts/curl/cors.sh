usage_cors() {
  cat <<-EOF
Usage: curl cors <test-url> <origin>

Test if the remote resource specified by <test-url> allows the browser to visit
from the <origin>. A preflight request is sent to the resource on the other
origin by using the OPTIONS method, in order to determine if the actual request
is safe to send.

The <test-url> may be a non-existent remote resource, though it will return 404
error, it can still show whether CORS is allowed.

The origin should be specified with below format:

  <scheme> "://" <hostname> [ ":" <port> ]

where scheme typically is http or https.

For more info, please visit https://developer.mozilla.org/en-US/docs/Web/HTTP/CORS

Options:
  -m <method> access control method to check if it is allowed
  -H <headers> access control headers to check if they are allowed, separated by comma

Example:
  $> curl cors http://example.com http://foo.example.com
EOF
  exit 1
}

cmd_cors() {
  local remainder=()
  local -a opts
  while [ $# -gt 0 ]; do
    case "$1" in
      -m)
        shift
        opts+=(-H "Access-Control-Request-Method: $1")
        ;;
      -H)
        shift
        opts+=(-H "Access-Control-Request-Headers: $1")
        ;;
      -*)
        usage_cors
        ;;
      *)
        remainder+=("$1")
        ;;
    esac
    shift
  done

  set - "${remainder[@]}"

  local url="$1"
  local origin="$2"
  if [ -z "$url" -o -z "$origin" ]; then
    usage_cors
  fi

  if [[ ! "$origin" =~ ^https?://[^/]+$  ]]; then
    # Ref: https://developer.mozilla.org/en-US/docs/Web/HTTP/Headers/Origin
    echo "Incorrect format for the origin. The correct format is as follows:"
    echo
    echo '<scheme> "://" <hostname> [ ":" <port> ]'
    exit 1
  fi

  source "$DOTFILES_DIR/scripts/lib/utils/common.sh"
  source "$DOTFILES_DIR/scripts/lib/io.sh"
  source "$DOTFILES_DIR/scripts/lib/utils/trim.sh"

  local output
  io_run_capture_and_display output curl -XOPTIONS -H "Origin: $origin" "$url" -D - -o /dev/null -sS "${opts[@]}"

  echo -e "----\n"

  source "$DOTFILES_DIR/scripts/lib/gsed.sh"
  local allowed_origin="$(str_trim "$(echo "$output" | grep -i Access-Control-Allow-Origin | "$SED" 's/^access-control-allow-origin:[[:space:]]*//i')")"
  if [ "$allowed_origin" = "$origin" -o "$allowed_origin" = "*" ]; then
    echo CORS is allowed.

    local allowed_methods="$(str_trim "$(echo "$output" | grep -i Access-Control-Allow-Methods | "$SED" 's/^access-control-allow-methods:[[:space:]]*//i')")"
    if [ -n "$allowed_methods" ]; then
      echo -n "Allowed methods: "
      echo "$allowed_methods"
    fi

    local allowed_headers="$(str_trim "$(echo "$output" | grep -i Access-Control-Allow-Headers | "$SED" 's/^access-control-allow-headers:[[:space:]]*//i')")"
    if [ -n "$allowed_headers" ]; then
      echo -n "Allowed headers: "
      echo "$allowed_headers"
    fi
  else
    echo CORS is NOT allowed.
  fi
}
