source "$(dirname "$BASH_SOURCE")/common.sh"

usage_fast_build() {
  cat <<-EOF
Usage: jdtls fast-build

Fast build eclipse.jdt.ls project.
EOF
  exit 1
}

cmd_fast_build() {
  # Ref: vscode-java gulpfile.js
  ./mvnw -o -pl org.eclipse.jdt.ls.core,org.eclipse.jdt.ls.target clean package -Declipse.jdt.ls.skipGradleChecksums
  cp org.eclipse.jdt.ls.core/target/org.eclipse.jdt.ls.core-1.11.0-SNAPSHOT.jar org.eclipse.jdt.ls.product/target/repository/plugins/org.eclipse.jdt.ls.core_1.11.0.202204191550.jar
}
