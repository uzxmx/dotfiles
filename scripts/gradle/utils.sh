usage_showRepos() {
  cat <<-EOF
Usage: gradle showRepos

Show repositories.
EOF
  exit 1
}

usage_showBuildScriptRepos() {
  cat <<-EOF
Usage: gradle showBuildScriptRepos

Show buildscript repositories.
EOF
  exit 1
}

usage_showBuildScriptClasspath() {
  cat <<-EOF
Usage: gradle showBuildScriptClasspath

Show buildscript classpath.

Options:
  -Pno_split do not split the classpath
EOF
  exit 1
}

def_task_cmds utils.gradle showRepos showBuildScriptRepos showBuildScriptClasspath
