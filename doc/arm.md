## Install arm toolchains on ubuntu

```
sudo apt-get install gcc-arm-linux-gnueabi

# The below may also work.
# sudo apt-get install gcc-arm-none-eabi
```

## Run arm program on x86 host

```
sudo apt-get install qemu
arm-linux-gnueabi-gcc -o main main.c
qemu-arm -L /usr/arm-linux-gnueabi main
```

## Build kernel for arm

```
wget https://cdn.kernel.org/pub/linux/kernel/v4.x/linux-4.14.7.tar.xz
tar xvJf linux-4.14.7.tar.xz
cd linux-4.14.7
make CROSS_COMPILE=arm-linux-gnueabi- ARCH=arm vexpress_defconfig
# Set CONFIG_DYNAMIC_DEBUG=y in .config to enable dynamic debug (pr_debug)
make CROSS_COMPILE=arm-linux-gnueabi- ARCH=arm
qemu-system-arm -M vexpress-a9 -m 512M -kernel linux-4.14.7/arch/arm/boot/zImage -dtb linux-4.14.7/arch/arm/boot/dts/vexpress-v2p-ca9.dtb -nographic -append "console=ttyAMA0"
```

## Quit from qemu

```
Press CTRL-A, and then press X
```

## Build rootfs

```
wget https://busybox.net/downloads/busybox-1.27.2.tar.bz2
tar xjvf busybox-1.27.2.tar.bz2
cd busybox-1.27.2
make defconfig
make menuconfig
# Busybox Settings --> Build Options --> [*] Build BusyBox as a static binary(no shared libs)
make CROSS_COMPILE=arm-linux-gnueabi-
make install CROSS_COMPILE=arm-linux-gnueabi-

cd ..
mkdir rootfs
cp -r busybox-1.27.2/_install/* rootfs/
# If we have built busybox as static binary, then we wouldn't need to do this.
# mkdir rootfs/lib
# cp -P /usr/arm-linux-gnueabi/lib/* rootfs/lib

# Make 4 tty devices
mkdir -p rootfs/dev
sudo mknod rootfs/dev/tty1 c 4 1
sudo mknod rootfs/dev/tty2 c 4 2
sudo mknod rootfs/dev/tty3 c 4 3
sudo mknod rootfs/dev/tty4 c 4 4

mkdir -p rootfs/proc
mkdir -p rootfs/sys

dd if=/dev/zero of=a9rootfs.ext3 bs=1M count=32
mkfs.ext3 a9rootfs.ext3
mkdir tmpfs
sudo mount -t ext3 a9rootfs.ext3 tmpfs/ -o loop
sudo cp -r rootfs/* tmpfs/
sudo umount tmpfs

# run with rootfs
qemu-system-arm -M vexpress-a9 -m 512M -kernel linux-4.14.7/arch/arm/boot/zImage -dtb linux-4.14.7/arch/arm/boot/dts/vexpress-v2p-ca9.dtb -nographic -append "root=/dev/mmcblk0 console=ttyAMA0 rw init=/linuxrc" -sd a9rootfs.ext3

# run with dyndbg (Documentation/admin-guide/dynamic-debug-howto.rst)
qemu-system-arm -M vexpress-a9 -m 512M -kernel linux-4.14.7/arch/arm/boot/zImage -dtb linux-4.14.7/arch/arm/boot/dts/vexpress-v2p-ca9.dtb -nographic -append 'root=/dev/mmcblk0 console=ttyAMA0 rw init=/linuxrc dyndbg="file drivers/of/* +p"' -sd a9rootfs.ext3
```

## Build kernel for x86_64

```
Refs:
http://nickdesaulniers.github.io/blog/2018/10/24/booting-a-custom-linux-kernel-in-qemu-and-debugging-it-with-gdb/

# The config file is located at arch/x86/configs/x86_64_defconfg
make x86_64_defconfig
# Add gdb support config to .config
./scripts/config -e DEBUG_INFO -e GDB_SCRIPTS

# -s shorthand for -gdb tcp::1234
# -S freeze CPU at startup (use 'c' to start execution)
# In order to use gdb, we must provide `nokaslr` to kernel params
qemu-system-x86_64 -kernel linux-4.14.7/arch/x86_64/boot/bzImage -hda rootfs.ext4 -append "console=ttyS0 root=/dev/sda init=/linuxrc nokaslr" -nographic -s -S

# One time setup
echo "add-auto-load-safe-path linux-4.14.7/scripts/gdb/vmlinux-gdb.py" >~/.gdbinit

# Connect to gdbserver and debug
# The way that disconnect and reconnect is a work around for error `Remote 'g' packet reply is too long`
gdb -ex "file vmlinux" \
    -ex 'set arch i386:x86-64:intel' \
    -ex 'target remote localhost:1234' \
    -ex 'break start_kernel' \
    -ex 'continue' \
    -ex 'disconnect' \
    -ex 'set arch i386:x86-64' \
    -ex 'target remote localhost:1234'
```
