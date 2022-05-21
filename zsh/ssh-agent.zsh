# Share a same ssh-agent across sessions.
if [ -f "$DOTFILES_TARGET_DIR/.ssh-agent.generated.env" ]; then
  . "$DOTFILES_TARGET_DIR/.ssh-agent.generated.env" >/dev/null
  # If the $SSH_AGENT_PID is occupied by other process, we need to manually remove "$DOTFILES_TARGET_DIR/.ssh-agent.generated.env".
  if ! kill -0 $SSH_AGENT_PID &>/dev/null; then
    # Stale ssh-agent env file found. Spawn a new ssh-agent.
    eval `ssh-agent | tee "$DOTFILES_TARGET_DIR/.ssh-agent.generated.env"`
    ssh-add
  fi
else
  eval `ssh-agent | tee "$DOTFILES_TARGET_DIR/.ssh-agent.generated.env"`
  ssh-add
fi
