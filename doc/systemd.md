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
