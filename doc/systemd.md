# Systemd

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