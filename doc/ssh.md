## Generate ssh key to a customized place

```
ssh-keygen -t rsa -f path-to-private-key-to-save

# For Mac OSX mojave, you may also need to add `-m PEM`
# Ref: https://serverfault.com/questions/939909/ssh-keygen-does-not-create-rsa-private-key
ssh-keygen -m PEM -t rsa -f path-to-private-key-to-save
```

## Generate public key from private key

```
ssh-keygen -y -f id_rsa >id_rsa.pub
```

## Agent forwarding

```
ssh -A user@host
```

If a new ssh agent is started in remote shell's initialization process, then agent forwarding will not work.
