[[ -f ~/.zshenv.pre.local ]] && source ~/.zshenv.pre.local

define_lazy_loader() {
  name=$1
  fn=$2
  alias_names=$3

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

export PATH="$HOME/.rbenv/bin:$PATH"
if [ $commands[rbenv] ]; then
  LOAD_RBENV_ALIASES=(rbenv ruby gem irb rails rake cap rspec bundle "${LOAD_RBENV_ALIASES_CUSTOM[@]}")
  load_rbenv_fn() {
    eval "$(command rbenv init -)"
    [ -s /etc/profile.d/rbenv.sh ] && . /etc/profile.d/rbenv.sh
  }
  define_lazy_loader rbenv load_rbenv_fn LOAD_RBENV_ALIASES
fi

if [ $commands[kubectl] ]; then
  LOAD_KUBECTL_ALIASES=(kubectl)
  load_kubectl_fn() {
  # TODO  load completion later
    if [ ! $commands[compdef] ]; then
      compinit
    fi
    source <(command kubectl completion zsh)
  }
  define_lazy_loader kubectl load_kubectl_fn LOAD_KUBECTL_ALIASES
fi

if [ -d "$HOME/.nvm" ]; then
  export NVM_DIR="$HOME/.nvm"
  if [ -s "$NVM_DIR/nvm.sh" ]; then
    LOAD_NVM_ALIASES=(nvm npm)
    load_nvm_fn() {
      \. "$NVM_DIR/nvm.sh"
      [ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"
    }
    define_lazy_loader nvm load_nvm_fn LOAD_NVM_ALIASES
  fi
fi

export SDKMAN_DIR="$HOME/.sdkman"
if [ -s "$HOME/.sdkman/bin/sdkman-init.sh" ]; then
  # Although javah is removed from java 10, some libraries may still depend on it. If we use a java version below 10
  # from sdkman, we want to trigger loading sdkman when executing javah.
  LOAD_SDKMAN_ALIASES=(sdk java javac javah)
  load_sdkman_fn() {
    source "$HOME/.sdkman/bin/sdkman-init.sh"
  }
  define_lazy_loader sdkman load_sdkman_fn LOAD_SDKMAN_ALIASES
fi

if [ -s "$HOME/.luaver/luaver" ]; then
  LOAD_LUAVER_ALIASES=(luaver)
  load_luaver_fn() {
    source "$HOME/.luaver/luaver"
  }
  define_lazy_loader luaver load_luaver_fn LOAD_LUAVER_ALIASES
fi

[[ -f ~/.zsh/aliases ]] && source ~/.zsh/aliases
