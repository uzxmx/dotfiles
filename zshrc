# Zsh 5.3.1 is required.

# Below code snippets may make zsh startup fast, but it's not the truth for my laptop.
# Based on my research, the most high cost is the call `compinit`, it makes the startup
# time 1x slower(from 0.8~ to 1.8~). Currently, it's better for me to enable it in shell
# manually. So I just comment below codes.
#
# Here's the quoted comment from https://gist.github.com/ctechols/ca1035271ad134841284:
#
# On slow systems, checking the cached .zcompdump file to see if it must be
# regenerated adds a noticable delay to zsh startup.  This little hack restricts
# it to once a day.  It should be pasted into your own completion file.
#
# The globbing is a little complicated here:
# - '#q' is an explicit glob qualifier that makes globbing work within zsh's [[ ]] construct.
# - 'N' makes the glob pattern evaluate to nothing when it doesn't match (rather than throw a globbing error)
# - '.' matches "regular files"
# - 'mh+24' matches files (or directories or whatever) that are older than 24 hours.
autoload -Uz compinit
# if [[ -n ${ZDOTDIR}/.zcompdump(#qN.mh+24) ]]; then
#   compinit
# else
#   compinit -C
# fi

# Bash-like help support. To find help files, we may also need to set HELPDIR environment variable with
# something like /path/to/zsh_help_directory.
unalias run-help 2>/dev/null
autoload run-help
alias help=run-help

source ~/.zsh_plugins.sh

PURE_PROMPT_VICMD_SYMBOL="[VIM]❯"

bindkey -v
bindkey "^A" beginning-of-line
bindkey "^E" end-of-line
bindkey "^P" up-line-or-search
bindkey "^N" down-line-or-search
bindkey '^F' forward-char
bindkey '^B' backward-char
bindkey '^R' history-incremental-search-backward
bindkey '^W' backward-kill-word
bindkey "^V" edit-command-line

# By default, there is a 0.4 second delay after you hit the <ESC> key and when
# the mode change is registered. This results in a very jarring and frustrating
# transition between modes. Let's reduce this delay to 0.1 seconds.
# This can result in issues with other terminal commands that depended on this
# delay. If you have issues try raising the delay.
export KEYTIMEOUT=1

# load custom executable functions
for function in ~/.zsh/functions/*; do
  source $function
done

# If you come from bash you might have to change your $PATH.
export PATH=$HOME/.local/bin:$HOME/.bin:$HOME/bin:/usr/local/bin:$PATH

_load_settings() {
  _dir="$1"
  if [ -d "$_dir" ]; then
    if [ -d "$_dir/pre" ]; then
      for config in "$_dir"/pre/**/*(N-.); do
        if [ ${config:e} = "zwc" ] ; then continue ; fi
        . $config
      done
    fi

    for config in "$_dir"/**/*(N-.); do
      case "$config" in
        "$_dir"/pre/*)
          :
          ;;
        "$_dir"/post/*)
          :
          ;;
        *)
          if [[ -f $config && ${config:e} != "zwc" ]]; then
            . $config
          fi
          ;;
      esac
    done

    if [ -d "$_dir/post" ]; then
      for config in "$_dir"/post/**/*(N-.); do
        if [ ${config:e} = "zwc" ] ; then continue ; fi
        . $config
      done
    fi
  fi
}
_load_settings "$HOME/.zsh/configs"

unsetopt share_history

# Change directory without prefix cd
setopt AUTO_CD

# Bash like completion
setopt noautomenu

if [ -e /usr/share/autojump/autojump.sh ]; then
  source /usr/share/autojump/autojump.sh
fi

[[ -f ~/.zshrc.platform ]] && source ~/.zshrc.platform
[[ -f ~/.zshrc.local ]] && source ~/.zshrc.local

# So as not to be disturbed by Ctrl-S ctrl-Q in terminals
stty -ixon

# If I execute command directly (not through binary under some directory), e.g. rails,
# I won't need to trigger load when directory is changed. So I just comment below codes.
#
# chpwd() {
#   if [ -f "$PWD/Gemfile" ]; then
#     if type load_rbenv >/dev/null; then
#       load_rbenv
#     fi
#   elif [ -f "$PWD/package.json" ]; then
#     if type load_nvm >/dev/null; then
#       load_nvm
#     fi
#   fi
# }

[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh
