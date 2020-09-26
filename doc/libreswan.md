## Troubleshooting

* error: 'IFLA_XFRM_IF_ID' undeclared (first use in this function)

IFLA_XFRM_IF_ID was added to mainline kernel 4.19 linux/if_link.h,
with older kernel headers 'make USE_XFRM_INTERFACE_IFLA_HEADER=true'

Add `USE_XFRM_INTERFACE_IFLA_HEADER=true` to `make`.

```
USE_XFRM_INTERFACE_IFLA_HEADER=true make programs
```

## Useful commands

```
# Traffic will be sent from ppp0. In captured packet, the dest ip may not be vpn server ip.
sudo tcpdump -n -i ppp0
```
