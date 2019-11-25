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

## On ubuntu `date` is not correct

```
# Make sure that ntp service is running
systemctl status ntp

# Or do one time update
sudo ntpdate ntp.ubuntu.com
```

## Split a large file into smaller parts

### Split

```
# Split log file into smaller files with 1000 lines per file.
split -l 1000 test.log test.log.

# Split image file into smaller files with 20k size per file.
split -b 20k  test.jpg test.jpg.

# Split image file into smaller files with 1024m size per file.
split -b 1024m  test.ios test.iso.
```

Notice: You may pass `-d` option to use number as generated name suffix. But on Mac OSX, `-d` option is not supported.

### Concatenate all smaller files together

```
cat [file-name-prefix]* >[new-file]
```

## Source code counter

```
go get -u github.com/boyter/scc/

# Count all
scc

# Only for app, lib
scc app lib

# Ignore csv files
scc -M '.csv' app lib

# Ignore csv and css files
scc -M '.csv|css' app lib
```
