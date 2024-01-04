usage_run_java() {
  cat <<-EOF
Usage: mvn run_java <main-class>

Example:
  $> mvn run_java foo.App
EOF
  exit 1
}

cmd_run_java() {
  mvn exec:java -Dexec.mainClass="$1"
}
