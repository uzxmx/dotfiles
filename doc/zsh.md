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
