settings="$HOME/.m2/settings.xml"

usage_mirror() {
  cat <<-EOF
Usage: mvn mirror [-e | -d]

Manage(show/enable/disable) aliyun mirror for maven. By default it shows
whether aliyun mirror is enabled.

Options:
  -e Enable aliyun mirror
  -d Disable aliyun mirror
EOF
  exit 1
}

aliyun_mirror_enabled() {
  [ -f "$settings" ]  && xmllint --xpath "//*[local-name()='mirror']/*[local-name()='id' and text()='aliyun']" "$settings" &>/dev/null;
}

show_aliyun_mirror() {
  if aliyun_mirror_enabled; then
    echo Aliyun mirror is enabled.
  else
    echo Aliyun mirror is NOT enabled.
  fi
}

enable_aliyun_mirror() {
  [ -f "$settings" ] || "$DOTFILES_DIR/bin/gen" mvn_settings --no-editor
  source "$DOTFILES_DIR/scripts/lib/awk/find_line.sh"
  source "$DOTFILES_DIR/scripts/lib/awk/insert_file.sh"

  local lineno="$(awk_find_line "$settings" "</mirrors>")"
  awk_insert_file - "$settings" "$lineno" <<EOF
<mirror>
  <id>aliyun</id>
  <mirrorOf>central</mirrorOf>
  <name>Aliyun mirror for maven</name>
  <url>http://maven.aliyun.com/nexus/content/groups/public</url>
</mirror>
EOF
}

# We disable the mirror by finding the line range which satisfies below pattern:
#
#   <mirror>
#     <id>aliyun</id>
#     ...
#   </mirror>
disable_aliyun_mirror() {
  source "$DOTFILES_DIR/scripts/lib/awk/find_line.sh"
  local range="$(awk_find_line_range "$settings" "<id>aliyun</id>" "<mirror>" "</mirror>")"
  [ -n "$range" ] && sed -i "$(echo "$range" | tr " " ,)d" "$settings"
}

cmd_mirror() {
  local action="show"
  while [ "$#" -gt 0 ]; do
    case "$1" in
      -e)
        action="enable"
        ;;
      -d)
        action="disable"
        ;;
      *)
        usage_mirror
        ;;
    esac
    shift
  done

  if [ "$action" = "enable" ]; then
    aliyun_mirror_enabled || enable_aliyun_mirror
  elif [ -f "$settings" -a "$action" = "disable" ]; then
    aliyun_mirror_enabled && disable_aliyun_mirror
  fi
  show_aliyun_mirror
}
