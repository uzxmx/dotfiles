usage_download_jar() {
  cat <<-EOF
Usage: mvn download_jar [-g <group_id>] [-a <artifact_id>] [-v <version>] [--with-source]

Download jar into ~/.m2 without using a pom.xml.

Example:
  $> mvn download_jar -g org.apache.maven.archetypes -a maven-archetype-archetype -v 1.4 --with-source
EOF
  exit 1
}

cmd_download_jar() {
  local group_id artifact_id version download_source
  while [ "$#" -gt 0 ]; do
    case "$1" in
      -g)
        group_id="$2"
        shift 2
        ;;
      -a)
        artifact_id="$2"
        shift 2
        ;;
      -v)
        version="$2"
        shift 2
        ;;
      --with-source)
        download_source=1
        shift
        ;;
      *)
        usage_download_jar
        ;;
    esac
  done
  source "$DOTFILES_DIR/scripts/lib/prompt.sh"
  ask_for_input group_id "Group id: "
  ask_for_input artifact_id "Artifact id: "
  ask_for_input version "Version: "
  local artifact="$group_id:$artifact_id:$version:jar"
  mvn dependency:get -Dartifact="$artifact"
  if [ "$download_source" = "1" ]; then
    mvn dependency:get -Dartifact="$artifact:sources"
  fi
}
