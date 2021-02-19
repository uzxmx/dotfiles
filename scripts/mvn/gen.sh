usage_gen() {
  cat <<-EOF
Usage: mvn gen

Generate a project from an archetype. If a desired archetype cannot be found,
you can first run 'remote_archetypes' subcommand to check if it exists in
remote. If not, you can make one and add it here for later use.
EOF
  exit 1
}

make_sure_artifact_exists() {
  local group_id="$1"
  local artifact_id="$2"
  local version="$3"

  source "$mvn_dir/download_jar.sh"
  if [ ! -f "$HOME/.m2/repository/$(echo $group_id | tr . /)/$artifact_id/$version/$artifact_id-$version.jar" ]; then
    cmd_download_jar -g  "$group_id" -a "$artifact_id" -v "$version"
  fi
}

cmd_gen() {
  # Each line of archetypes is of such format:
  #
  #   <description>\t<group_id>:<artifact_id>:<version>
  #
  # If group id is omitted, it defaults to `org.apache.maven.archetypes` which
  # is the official group for archetypes.
  local archetypes="Template archetype\t:maven-archetype-archetype:1.4
Simple Java project\t:maven-archetype-quickstart:1.4
Simple web project\t:maven-archetype-webapp:1.4
Spring boot simple sample\torg.springframework.boot:spring-boot-sample-simple-archetype:1.0.2.RELEASE
Spring boot webmvc project\tio.fabric8.archetypes:spring-boot-webmvc-archetype:2.2.197"

  local line="$(echo -e "$archetypes" | fzf -d "\t" --with-nth=1)"
  [ -z "$line" ] && exit
  local archetype="$(echo "$line" | awk -F "\t" '{print $2}')"
  local group_id="$(echo "$archetype" | awk -F: '{print $1}')"
  group_id="${group_id:-org.apache.maven.archetypes}"
  local artifact_id="$(echo "$archetype" | awk -F: '{print $2}')"
  local version="$(echo "$archetype" | awk -F: '{print $3}')"

  make_sure_artifact_exists "$group_id" "$artifact_id" "$version"

  # The value for `archetypeCatalog` can be `internal`, `local` and `remote`.
  # When using `local`, mvn won't check remote archetypes, this will be faster.
  # For more info, see
  # `https://maven.apache.org/archetype/maven-archetype-plugin/specification/archetype-catalog.html`.
  mvn archetype:generate -DarchetypeCatalog=local \
    -DarchetypeGroupId="$group_id" \
    -DarchetypeArtifactId="$artifact_id" \
    -DarchetypeVersion="$version"
}
