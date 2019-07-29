## Process management

```
# Show process tree
pstree -aps <pid>

# Show ppid (https://unix.stackexchange.com/questions/237214/how-to-get-ppid-with-ps-aux-under-aix
)
ps -ef

# `ps aux` v.s. `ps -ef`

# Show thread id (SPID)
ps -eT

# Show process threads
ps huH
ps huH <pid>
```

## Logrotate immediately

```
logrotate --force /etc/logrotate.d/some-file
```

## Create a new partition and format with ext4

```
# Suppose a new device is /dev/sdb
sudo fdisk /dev/sdb
sudo mkfs.ext4 /dev/sdb1
```

## Extract cpio file

```
cat file | cpio -idmv
```

## Make cpio

```
find . | cpio -o -Hnewc | gzip -9 > ../image.cpio.gz
```

## Loop devices

```
# List loop devices and associated files
losetup -l

# Associate /dev/loop0 with file
losetup /dev/loop0 file

# Detach /dev/loop0
losetup -d /dev/loop0
```

## Mount disk file

```
# Mount as readonly filesystem
sudo mount -o loop,ro path-to-image-file mount-point

# Mount as readwrite filesystem
sudo mount -o loop,rw path-to-image-file mount-point
```
