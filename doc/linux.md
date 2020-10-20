## Process management

```
# Show process tree
pstree
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

## How to use different network interfaces for different processes?

```
# Use `ifconfig` to find network interface ip address.

# For wget
wget --bind-address <network-interface-ip-address> ...

# For curl
curl --interface <network-interface-name> ...
```

* Refs

https://superuser.com/questions/241178/how-to-use-different-network-interfaces-for-different-processes
http://daniel-lange.com/archives/53-Binding-applications-to-a-specific-IP.html
https://serverfault.com/questions/496731/how-to-set-which-ip-to-use-for-a-http-request

## How to use tcpdump?

```
# Listen on localhost interface
tcpdump -i lo

# Listen on eth0 interface
tcpdump -i eth0

# Listen on all interfaces
tcpdump -i any

tcpdump -i any port 8080
tcpdump -i any dst port 8080 and src 172.0.0.3

# Print all packets arriving at or departing from 172.0.0.3
tcpdump host 172.0.0.3
```

## Netcat

Some netcat implementation doesn't support `-z` option.

```
# Act as chat server, listen at 2399
nc -l 1234

# Act as chat client
nc localhost 1234

# Only scan with verbose output
nc -z -v example.com 80

# Test connection with 5s timeout
nc -z -v -w 5 example.com 80

# For UDP port
nc -z -v -u example.com 888
```

## screen

```
# List sessions
screen -ls

# Reattach to a detached screen process
screen -r

Reattach if possible, otherwise start a new session
screen -R
```

## How to use dig?

```
dig @nameserver hostname
dig @8.8.8.8 google.com
dig @8.8.4.4 google.com
```

## tar

```
# List tar contents
tar ztvf foo.tar.gz

# Extract tar without root directory
tar zxvf foo.tar.gz --strip-components=1
```

## User management

```
# List all groups
getent group

# Show current user groups
groups
id

# Append a user to newgroup (need to re-login)
usermod -a -G newgroup user

# Remove a user from a group (need to re-login)
gpasswd -d user group
```

## Pipe stdout while keeping it on screen

```
echo foo | tee >(grep foo)

echo foo | tee /dev/tty | grep foo
```

Ref:

* http://www.gnu.org/savannah-checkouts/gnu/bash/manual/bash.html#Process-Substitution
* https://stackoverflow.com/a/5677265

## Change ls colors

```
man dircolors
```

Ref:

* https://unix.stackexchange.com/a/94505
* http://www.bigsoft.co.uk/blog/2008/04/11/configuring-ls_colors

## GNU coreutils

```
# Compare two sorted files line by line
# man comm
comm foo.txt bar.txt

# man join
```

## VT OSC

```
echo -en "\e[1;97;41m"
echo -en "\e[1;97;42m"

# Copy contents to system clipboard. Contents should be base64 encoded.
echo -en "\e]52;;Zm9v\a"
echo -en "\e]52;;Zm9vDQpiYXI=\a"
```

Ref: https://invisible-island.net/xterm/ctlseqs/ctlseqs.html

## Generate random permutations

```
shuf -n 1 /usr/share/dict/words
echo "0\n1" | shuf -n 1
```

## Use mirror for ubuntu apt-get

```
sudo sed -i.bak -Ee 's:[0-9a-zA-Z]+\.ubuntu\.com/ubuntu/:mirrors.tuna.tsinghua.edu.cn/ubuntu/:' /etc/apt/sources.list
sudo apt-get update
```

## Use mirror for centos yum

```
sudo sed -i.bak -e 's;^mirrorlist=;#mirrorlist=;' -e 's;^#baseurl=http://mirror\.centos\.org;baseurl=https://mirrors.tuna.tsinghua.edu.cn;' /etc/yum.repos.d/CentOS-Base.repo
sudo yum makecache
```

## Mirrors for alpine

```
sed -i 's/dl-cdn.alpinelinux.org/mirrors.tuna.tsinghua.edu.cn/g' /etc/apk/repositories
```

Other mirrors include:

* mirrors.ustc.edu.cn
* mirrors.aliyun.com

Ref:

* https://mirrors.alpinelinux.org/
* https://mirrors.tuna.tsinghua.edu.cn/help/alpine/
* https://mirrors.ustc.edu.cn/help/alpine.html
* https://developer.aliyun.com/mirror/alpine

## stty sane

In a terminal, when you encounter some weird problem about input or display, you
can run `stty sane` to restore terminal settings.

## Cross toolchain

* http://crosstool-ng.github.io/docs/
* https://releases.linaro.org/components/toolchain/binaries/
