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

## SSH Command

```
Press `enter` `~` `?` to show help
Press `enter` `~` `.` to terminate connection
```

### Force ssh client to use password authentication

```
ssh -o PreferredAuthentications=password -o PubkeyAuthentication=no user@host
```

> Make sure `/etc/ssh/sshd_config` is configured with `PasswordAuthentication yes`, otherwise
the connection will be closed.

## keyboard-interactive authentication

If you want to use keyboard-interactive authentication, you may need to configure `/etc/ssh/sshd_config`:

```
PasswordAuthentication no
ChallengeResponseAuthentication yes
```

Then execute:

```
ssh -o PreferredAuthentications=keyboard-interactive user@host
```

## Agent forwarding

```
ssh -A user@host
```

If a new ssh agent is started in remote shell's initialization process, then agent forwarding will not work.

### Test if a ssh key works for a connection

```
ssh -o IdentitiesOnly=yes -i <pem-file> user@host
```

Note that `-o IdentitiesOnly=yes` is important, because it prevents ssh client
using keys from ssh-agent.

Ref: https://superuser.com/a/436015

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

## Useful links

https://superuser.com/questions/421997/what-is-a-ssh-key-fingerprint-and-how-is-it-generated
https://security.stackexchange.com/questions/41380/are-duplicate-ssh-server-host-keys-a-problem

## How to run sshd on WSL Ubuntu?

```
service ssh status
service ssh start

# Use below command to debug.
sudo /usr/sbin/sshd -d

# Make sure three types (rsa, ecdsa, ed25519) of keys exist in /etc/ssh/.
sudo ssh-kengen -t <type> -f /etc/ssh/ssh_host_<type>_key
```
