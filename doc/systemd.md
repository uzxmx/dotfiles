# Systemd

## systemctl

```
# List all services
systemctl -t service -a

systemctl list-units
systemctl list-unit-files

# Find service status
systemctl status <service>

systemctl is-enabled <service>
systemctl is-active <service>

# Enable service on boot up
systemctl enable <service>

# Disable service on boot up
systemctl disable <service>

# Start, stop or restart
systemctl start <service>
systemctl stop <service>
systemctl restart <service>

man systemd.unit
man systemd.service
```

## Notes on environment variables

`systemd.service` manual says:

> Basic environment variable substitution is supported. Use "${FOO}" as part of a word, or as a word of its own, on the command line, in which case it will be replaced by the value of the
> environment variable including all whitespace it contains, resulting in a single argument. Use "$FOO" as a separate word on the command line, in which case it will be replaced by the value of the
> environment variable split at whitespace resulting in zero or more arguments. For this type of expansion, quotes and respected when splitting into words, and afterwards removed.

To clarify:

If "$FOO" is used when the character before "$" is not a whitespace, the
variable won't be substituted. In that situation, "${FOO}" should be used.

```
[Service]
Environment=FOO=bar
ExecStart=/bin/echo --long-opts=$FOO
```

Above config won't work as expected. But below works.

```
[Service]
Environment=FOO=bar
ExecStart=/bin/echo --long-opts=${FOO}
```

## journalctl

```
# Show logs for a systemd service
journalctl -u ssh

# Show kernel message
journalctl -k

# Monitor new log messages
journalctl -f
journalctl -u <service-name> -f
```

# SysVInit

```
service --status-all
```

According to ansible service module, init systems include BSD init, OpenRC, SysV, Solaris SMF, systemd, upstart.
Ref: https://docs.ansible.com/ansible/latest/modules/service_module.html

We can use `chkconfig` command to update and query runlevel information for
system services.

```
chkconfig --list
chkconfig --list nginx

# Start nginx on boot
chkconfig nginx off

# Do not start nginx on boot
chkconfig nginx off
```

Below are some useful commands about runlevel:

```
# Get current run level
runlevel

man runlevel
man 7 runlevel
```
