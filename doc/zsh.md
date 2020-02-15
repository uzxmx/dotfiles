## Commands

```
zsh --help

# Start a non-interactive shell
zsh -c 'some-command'

# Start an interactive shell
zsh -ic

# Start an interactive login shell
zsh -ilc
```

## Execution order and condition for `zshenv`, `zprofile`, `zshrc`, `zlogin`

See `man zsh`, section `STARTUP/SHUTDOWN FILES`.

## Zsh Line Editor

For more info, please see `man zshzle`

### How to use bindkey?

```
# Show bound keys.
bindkey

# List all existing keymap names.
bindkey -l

# List all existing keymap names and how they are created.
bindkey -lL

# Unbind the specified in-strings in the selected keymap. (e.g. bind -r "^[")
bindkey -r in-string ...
```

### How to execute command directly in a widget function?

```
BUFFER="the-command-to-be-executed"
zle redisplay
zle accept-line
```

### How to add something to zsh history?

Use `print -s`

Ref: https://stackoverflow.com/a/2816792

## `time echo` shows nothing

Additional note: The time builtin applied to any construct that is executed in the current shell,
is silently ignored. So although it's syntactically OK to put an opening curly or a repeat-loop
or the like immediately after the time keyword, you'll get no timing statistics. You have to use
parens instead, to force a subshell, which is then timed.

```
time (echo)
```

Ref: https://unix.stackexchange.com/a/427377
