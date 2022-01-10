usage_list_profiles() {
  cat <<-EOF
Usage: xcodeutils list_profiles

List profiles on current system.

Note: it's better to understand App ID, Certificate and Profile.

An App ID can enable many capabilities. When capabilities are updated, all
profiles will be invalid and should be regenerated.

A profile, which corresponds to a .mobileprovision file on a system, contains
attributes such as name, type(e.g. development), app id, and one or more
certificates, one or more devices, and expiration time.
EOF
  exit 1
}

cmd_list_profiles() {
  local -a profiles
  get_profiles --valid --format full_no_path
  (IFS=$'\n'; echo "${profiles[*]}" | column -t -s "!")
}
