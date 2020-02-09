## How to list all key bindings?

```
<prefix-key> :list-keys
<prefix-key> :list-keys -T copy-mode-vi
```

## How to use tmux variables?

`window_zoomed_flag` is a tmux variable that indicates whether current window is zoomed.
For more variables, please use `man tmux`.

```
bind-key -n C-l if-shell "[ '#{window_zoomed_flag}' -ne '1' ]" "display-message 'not zoomed'"
bind-key -n C-l if-shell "$is_vim" "send-keys C-l" "if-shell \"[ '#{window_zoomed_flag}' -ne '1' ]\" \"select-pane -R\""
bind-key -T copy-mode-vi C-l if-shell "[ '#{window_zoomed_flag}' -ne '1' ]" "select-pane -R"
```

## How does vim-tmux-navigator disable navigation when window is zoomed?

```
tmux bind-key -n C-h if-shell "$is_vim" "send-keys C-h" "if-shell \"[ '#{window_zoomed_flag}' -ne '1' ]\" \"select-pane -L\""
tmux bind-key -n C-j if-shell "$is_vim" "send-keys C-j" "if-shell \"[ '#{window_zoomed_flag}' -ne '1' ]\" \"select-pane -D\""
tmux bind-key -n C-k if-shell "$is_vim" "send-keys C-k" "if-shell \"[ '#{window_zoomed_flag}' -ne '1' ]\" \"select-pane -U\""
tmux bind-key -n C-l if-shell "$is_vim" "send-keys C-l" "if-shell \"[ '#{window_zoomed_flag}' -ne '1' ]\" \"select-pane -R\""
tmux bind-key -n C-\\ if-shell "$is_vim" "send-keys C-\\" "if-shell \"[ '#{window_zoomed_flag}' -ne '1' ]\" \"select-pane -l\""
tmux bind-key -T copy-mode-vi C-h if-shell "[ '#{window_zoomed_flag}' -ne '1' ]" "select-pane -L"
tmux bind-key -T copy-mode-vi C-j if-shell "[ '#{window_zoomed_flag}' -ne '1' ]" "select-pane -D"
tmux bind-key -T copy-mode-vi C-k if-shell "[ '#{window_zoomed_flag}' -ne '1' ]" "select-pane -U"
tmux bind-key -T copy-mode-vi C-l if-shell "[ '#{window_zoomed_flag}' -ne '1' ]" "select-pane -R"
tmux bind-key -T copy-mode-vi C-\\ if-shell "[ '#{window_zoomed_flag}' -ne '1' ]" "select-pane -l"
```

## Prevent Logoff from Killing tmux Session

Ref: https://unix.stackexchange.com/questions/490267/prevent-logoff-from-killing-tmux-session

There may be another reason for this problem, if you use bash and the environment variable
`TMOUT` exists and is not zero, the shell will close automatically after being idle for `TMOUT`
seconds, which results in tmux session termination. For man info, refer to `man bash`.
