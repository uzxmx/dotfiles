## SFTP login with username and password

```
# This command will ask for password.
sftp -P port -o HostKeyAlgorithms=+ssh-dss user@host
sftp -P port -o PreferredAuthentications=password -o PubkeyAuthentication=no -o HostKeyAlgorithms=+ssh-dss user@host

# We can also use `lftp` to connect to SFTP server.
lftp -e "set sftp:connect-program ssh -o HostKeyAlgorithms=+ssh-dss" -u user,password sftp://host:port
```

> Make sure `/etc/ssh/sshd_config` is configured with `PasswordAuthentication yes`, otherwise
the connection will be closed.

## Basic commands

```
# Show help.
help
# or
?

# Create dir foo.
mkdir foo

# List files
ls
ls foo

# Change to dir foo.
cd foo
```

## Remove directory

```
# Remove dir foo.
# You can only remove a dir when it's an empty dir.
rmdir foo

# If you want to remove a dir recursively, you can use `lftp` to connect to the server.
rm -rf foo
```

## Upload files

```
# Upload a local file to remote.
put local-path-to-file

# Upload a non-empty directory to remote recursively.
# Ensure a same name directory on the remote exists. Then execute
put -r foo
```

## Download files

```
# Download a regular file.
get regular-file

# Download a folder recursively.
get -r foo
```

## Configure machine to be a SFTP server

Just start `sshd` service on that machine, then you can use `sftp` command to connect
with that machine. If you want to authenticate with password, you need to configure
`/etc/ssh/sshd_config` with `PasswordAuthentication yes`.
