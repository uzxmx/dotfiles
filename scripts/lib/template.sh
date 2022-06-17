#!/bin/sh

# This function renders a shell template file.
#
# @params:
#   $1: shell template file
#
# Note: characters like " | $ ` must be escaped.
#
# @example:
#   # Render a json template file.
#   cat <<EOF >foo.tpl.sh
#   {
#     \"codeLens.subseparator\": \"|\"
#   }
#   EOF
#
#   # Render a yaml template file.
#   ACCESS_KEY="foo"
#   WILDCARD=1
#   DOMAIN="example.com"
#   cat <<-EOF >bar.tpl.sh
#   data:
#     key: \"$(echo $ACCESS_KEY | base64)\"
#   dnsNames:
#     - $DOMAIN
#   $(sh -c "
#     if [ -n '$WILDCARD' ]; then
#     echo '\
#     - *.$DOMAIN
#   '
#     fi
#   ")
#   EOF
render_shell_template_file() {
  eval "echo -e \"$(cat "$1")\""
}
