usage_sdk() {
  sdkmanager --help
  exit 1
}

cmd_sdk() {
  sdkmanager "$@"
}
alias_cmd s sdk
