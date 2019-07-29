# Network

## Show network card ip addr

```
ifconfig
ifconfig enp0s9
ip addr
```

## Assign static ip to network card

```
sudo ifconfig enp0s9 192.168.102.2 netmask 255.255.255.0 up
```
