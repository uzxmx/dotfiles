## How to setup a shadowsocks relay?

If you want your client connected to a Japan VPS, but you want a US IP.

```
Client <--> Japan VPS <--> US VPS
```

### Using iptables

```
echo 1 > /proc/sys/net/ipv4/ip_forward
iptables -t nat -A PREROUTING -p tcp --dport 8388 -j DNAT --to-destination US_VPS_IP:8388
iptables -t nat -A POSTROUTING -p tcp -d US_VPS_IP --dport 8388 -j SNAT --to-source JAPAN_VPS_IP
```

### Using haproxy

Ref: https://github.com/shadowsocks/shadowsocks/wiki/Setup-a-Shadowsocks-relay

## TODO multiple users

ref: https://github.com/shadowsocks/shadowsocks/wiki/Manage-Multiple-Users
