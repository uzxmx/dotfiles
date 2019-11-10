#!/bin/sh

# Define lazy loader. Loading will be triggered by passed array of aliases.
#
# @params:
#   $1: the loader name
#   $2: the function to load lazily
#   $3: the array of alias names
#
# @example
#   LOAD_RBENV_ALIASES=(rbenv ruby gem irb rails rake cap rspec bundle "${LOAD_RBENV_ALIASES_CUSTOM[@]}")
#   load_rbenv_fn() {
#     eval "$(command rbenv init -)"
#     [ -s /etc/profile.d/rbenv.sh ] && . /etc/profile.d/rbenv.sh
#   }
#   define_lazy_loader rbenv load_rbenv_fn LOAD_RBENV_ALIASES
define_lazy_loader() {
  local name=$1
  local fn=$2
  local alias_names=$3

  eval "$(cat <<EOF
    load_$name() {
      # Unalias first to avoid recursion
      local alias_names=$alias_names
      for i in \${(P)\${alias_names}}; do
        unalias \$i
      done

      echo "Lazy load $name..." >/dev/stderr
      $fn

      unset -f load_$name
      unset -f $fn

      if [ \$# -gt 0 ]; then
        \$@
      fi
    }

    for i in \${(P)\${alias_names}}; do
      alias \$i="load_$name \$i"
    done
EOF
)"
}
