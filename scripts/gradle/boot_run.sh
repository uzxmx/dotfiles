usage_boot_run() {
  cat <<-EOF
Usage: gradle boot_run

Run spring-boot based project. To run this command successfully, you must
specify 'org.springframework.boot' plugin in your build.gradle.

If you want to launch multiple instances of a same spring application, you must
specify '--skip-compile-java' to compile java only once. Otherwise, the other
servers will be affected when you start a new one.

* Active profile

It will also ask you to specify an active spring profile. This relies on gradle
4.9+ which enables you to pass arguments to a JavaExec task (see
https://docs.gradle.org/current/javadoc/org/gradle/api/tasks/JavaExec.html#setArgsString-java.lang.String-).

* Auto-restart

When in tmux environment, this command also forks a process to build
continuously, which is required when spring-boot-devtools is used to
auto-restart the server. To use spring-boot-devtools, specify it in
build.gradle the below way:

dependencies {
  runtime 'org.springframework.boot:spring-boot-devtools'
}

Options:
  -p <profile> profile to use, default is dev
  --extra-profiles <profiles> extra profiles to use, separated by comma
  --boot-properties <properties> spring boot properties
  -d enable jvm debug, this will make jvm listen at 5005 to wait for debug
  --skip-compile-java
  -- delimit the start for java args
EOF
  exit 1
}

# TODO the auto-restart is slow to perform and may not work every time.
cmd_boot_run() {
  local extra_profiles boot_properties
  local -a opts
  local -a java_args
  local -a gradle_opts
  while [ "$#" -gt 0 ]; do
    case "$1" in
      -p)
        shift
        profile="$1"
        ;;
      --extra-profiles)
        shift
        extra_profiles="$1"
        ;;
      --boot-properties)
        shift
        boot_properties="$1"
        ;;
      -d)
        opts+=(--debug-jvm)
        ;;
      --skip-compile-java)
        gradle_opts+=(-x compileJava)
        ;;
      --)
        shift
        while [ "$#" -gt 0 ]; do
          java_args+=("$1")
          shift
        done
        break
        ;;
      *)
        usage_boot_run
        ;;
    esac
    shift
  done

  # if [ -n "$TMUX" ]; then
  #   # Skip test
  #   tmux split-window -h "$gradle_bin" build --continuous -x test
  # fi

  local profiles="${profile:-dev}"
  if [ -n "$extra_profiles" ]; then
    profiles="$profiles,$extra_profiles"
  fi
  "$gradle_bin" bootRun --args="--spring.profiles.active=$profiles $boot_properties ${opts[@]} ${java_args[*]}" "${gradle_opts[@]}"
}
