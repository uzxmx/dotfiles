# NFS

## Setup NFS on ubuntu 16.04

```
sudo apt-get install nfs-kernel-server

# Add export to /etc/exports
/srv/nfs *(rw,insecure,sync,no_root_squash,no_subtree_check)

# Restart nfs server
sudo systemctl restart nfs-kernel-server
```

## exportfs

```
# Reload /etc/exports
sudo exportfs -ra
```

## Show remote NFS mounts on host

```
# Show exports list
showmount -e 192.168.101.2
```

## Mount NFS directory

```
mount 192.168.101.2:/srv/nfs mountpoint
mount -t nfs 192.168.101.2:/srv/nfs mountpoint
mount -o rw -t nfs 192.168.101.2:/srv/nfs mountpoint
mount -o resvport,rw -t nfs 192.168.101.2:/srv/nfs mountpoint
```
