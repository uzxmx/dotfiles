source "$(dirname "$BASH_SOURCE")/common.sh"

usage_run() {
  cat <<-EOF
Usage: jdtls run

Run jdtls server.

Options:
  -d Wait for java debugger to attach
EOF
  exit 1
}

cmd_run() {
  local use_debugger
  while [ "$#" -gt 0 ]; do
    case "$1" in
      -d)
        use_debugger=1
        ;;
      *)
        usage_run
        ;;
    esac
    shift
  done

  # According to [this](https://github.com/eclipse/eclipse.jdt.ls#managing-connection-types),
  # to use socket to connect to the server, the jdtls client must be started first
  # and listening at CLIENT_PORT to wait for the server to connect.
  # TODO warn the client should be started first.
  if [ -z "$CLIENT_HOST" ]; then
    export CLIENT_HOST=127.0.0.1
  fi
  if [ -z "$CLIENT_PORT" ]; then
    export CLIENT_PORT=3333
  fi

  local -a opts
  if [ "$use_debugger" = "1" ]; then
    opts+=("-agentlib:jdwp=transport=dt_socket,server=y,suspend=y,address=53977")
  fi

  env socket.stream.debug=true java \
     "${opts[@]}" \
    -Declipse.application=org.eclipse.jdt.ls.core.id1 \
    -Dosgi.bundles.defaultStartLevel=4 \
    -Declipse.product=org.eclipse.jdt.ls.core.product \
    -Dlog.level=ALL \
    -noverify \
    -Xmx1G \
    --add-modules=ALL-SYSTEM \
    --add-opens java.base/java.util=ALL-UNNAMED \
    --add-opens java.base/java.lang=ALL-UNNAMED \
    -jar org.eclipse.jdt.ls.product/target/repository/plugins/org.eclipse.equinox.launcher_1.6.400.v20210924-0641.jar \
    -configuration org.eclipse.jdt.ls.product/target/repository/config_mac \
    -data /Users/xmx/.config/coc/extensions/coc-java-data/jdt_ws_156a2507632dd381cff02d4c4f869af8 -consoleLog
}
