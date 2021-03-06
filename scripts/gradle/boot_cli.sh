source "$gradle_dir/boot_run.sh"

usage_boot_cli() {
  cat <<-EOF
Usage: gradle boot_cli -n <cli-profile>

Options:
  -n <cli-profile> CLI profile to use, can omit 'cli.' prefix
  -p <profile> profile to use, default is dev
  --extra-profiles <profiles> extra profiles to use, separated by comma
  --boot-properties <properties> spring boot properties
  -- delimit the start for java args
EOF
  exit 1
}

cmd_boot_cli() {
  local cli_profile extra_profiles boot_properties
  local -a remainder
  while [ "$#" -gt 0 ]; do
    case "$1" in
      -n)
        shift
        cli_profile="$1"
        ;;
      --extra-profiles)
        shift
        extra_profiles="$1"
        ;;
      --boot-properties)
        shift
        boot_properties="$1"
        ;;
      -h)
        usage_boot_cli
        ;;
      *)
        remainder+=("$1")
        ;;
    esac
    shift
  done

  if [ -z "$cli_profile" ]; then
    local candidates="$(find . -name "*.java" | xargs grep -h '^@Profile("cli\..*")$')"
    if [ -n "$candidates" ]; then
      candidates="$(echo "$candidates" | sed 's/^@Profile("cli\.\(.*\)")$/\1/')"
    fi
    if [ -n "$candidates" ]; then
      cli_profile="$(echo "$candidates" | fzf)"
    fi
  fi

  [ -z "$cli_profile" ] && echo "A CLI profile is required" && exit 1

  if [[ ! "$cli_profile" =~ ^cli\. ]]; then
    cli_profile="cli.$cli_profile"
  fi

  if [ -z "$extra_profiles" ]; then
    extra_profiles="$cli_profile"
  else
    extra_profiles="$cli_profile,$extra_profiles"
  fi

  boot_properties="$boot_properties --spring.main.web-application-type=NONE"

  cmd_boot_run --extra-profiles "$extra_profiles" --boot-properties "$boot_properties" "${remainder[@]}"
}
