source "$(dirname "$BASH_SOURCE")/common.sh"

# TODO https://superuser.com/questions/181517/how-to-execute-a-command-whenever-a-file-changes
usage_watch() {
  cat <<-EOF
Usage: jdtls watch

watch jdtls server.
EOF
  exit 1
}

cmd_watch() {
  java \
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
    -data /Users/xmx/.config/coc/extensions/coc-java-data/jdt_ws_156a2507632dd381cff02d4c4f869af8
}
