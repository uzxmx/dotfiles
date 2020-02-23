## sshkey-gen

```
# Generate ssh key to a customized place
ssh-keygen -t rsa -f path-to-private-key-to-save

# For Mac OSX mojave, you may also need to add `-m PEM`
# Ref: https://serverfault.com/questions/939909/ssh-keygen-does-not-create-rsa-private-key
ssh-keygen -m PEM -t rsa -f path-to-private-key-to-save

# Generate public key from private key
ssh-keygen -y -f id_rsa >id_rsa.pub

# Show fingerprint
ssh-keygen -E md5 -lf id_rsa
ssh-keygen -E md5 -lf id_rsa.pub
```

## Force ssh client to use password authentication

```
ssh -o PreferredAuthentications=password -o PubkeyAuthentication=no user@host
```

## Agent forwarding

```
ssh -A user@host
```

If a new ssh agent is started in remote shell's initialization process, then agent forwarding will not work.

## SSH Command

```
Press `enter` `~` `?` to show help
Press `enter` `~` `.` to terminate connection
```

##  Run a command on local machine while on ssh in bash

https://stackoverflow.com/questions/38567427/run-a-command-on-local-machine-while-on-ssh-in-bash

https://superuser.com/questions/322757/reverse-tunnel-commands-through-ssh

How to support navigation when starting a ssh session in a tmux pane and executing vim on remote machine?

* tmux -> remote vim

we can check if vim is running by pane title.
Ref: https://github.com/christoomey/vim-tmux-navigator/blob/master/vim-tmux-navigator.tmux

* remote vim -> tmux

We can create a server on local machine which executes commands from remote machine. That server will listen at some port, and that port can be tunneled to remote through ssh.

Question: Is the tunnel secure?

https://github.com/ptenteromano/remote-shell-OS
